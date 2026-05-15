package com.chf.bbcms.meeting.adapter.out.persistence;

import com.chf.bbcms.meeting.application.port.out.MeetingRepository;
import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingPicture;
import com.chf.bbcms.meeting.domain.MeetingPresence;
import com.chf.bbcms.meeting.domain.MeetingStatus;
import com.chf.bbcms.meeting.domain.MeetingType;
import com.chf.bbcms.meeting.domain.PresenceRole;
import com.chf.bbcms.people.domain.Department;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;

@Repository
public class R2dbcMeetingRepository implements MeetingRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcMeetingRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<Meeting> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), MeetingRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<Meeting> findByBibleClub(UUID bibleClubId) {
        return template.select(MeetingRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all().flatMap(this::toDomain);
    }

    @Override
    public Flux<Meeting> findByStatus(MeetingStatus status) {
        return template.select(MeetingRow.class)
                .matching(Query.query(Criteria.where("status").is(status.name())))
                .all().flatMap(this::toDomain);
    }

    @Override
    public Flux<Meeting> findRecordedSince(LocalDate since) {
        return template.select(MeetingRow.class)
                .matching(Query.query(Criteria.where("status").is(MeetingStatus.RECORDED.name())
                        .and("date_occurred").greaterThanOrEquals(since)))
                .all().flatMap(this::toDomain);
    }

    @Override
    public Mono<Meeting> save(Meeting m) {
        MeetingRow row = toRow(m);
        Mono<MeetingRow> saved = (row.getId() == null ? template.insert(row) : template.update(row));
        return saved.flatMap(persisted -> persistJoinTables(persisted.getId(), m).thenReturn(persisted))
                .flatMap(this::toDomain);
    }

    private Mono<Void> persistJoinTables(UUID id, Meeting m) {
        Mono<Void> levels = client.sql("DELETE FROM bbcms_meeting_levels_concerned WHERE meeting_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(m.getLevelsConcerned())
                        .flatMap(lid -> client.sql("INSERT INTO bbcms_meeting_levels_concerned(meeting_id, level_id) VALUES(:m,:l)")
                                .bind("m", id).bind("l", lid).then()))
                .then();
        Mono<Void> bbcs = client.sql("DELETE FROM bbcms_meeting_bbc_concerned WHERE meeting_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(m.getBibleClubsConcerned())
                        .flatMap(bid -> client.sql("INSERT INTO bbcms_meeting_bbc_concerned(meeting_id, bible_club_id) VALUES(:m,:b)")
                                .bind("m", id).bind("b", bid).then()))
                .then();
        return levels.then(bbcs);
    }

    @Override
    public Flux<MeetingPresence> findPresences(UUID meetingId) {
        return client.sql("SELECT * FROM bbcms_meeting_presence WHERE meeting_id = :id")
                .bind("id", meetingId)
                .map((row, m) -> MeetingPresence.rehydrate(
                        row.get("id", UUID.class),
                        row.get("meeting_id", UUID.class),
                        row.get("member_id", UUID.class),
                        row.get("visitor_id", UUID.class),
                        row.get("present_at", Instant.class),
                        PresenceRole.valueOf(row.get("role", String.class))))
                .all();
    }

    @Override
    public Mono<Void> savePresences(UUID meetingId, List<MeetingPresence> presences) {
        Mono<Void> deleteOld = client.sql("DELETE FROM bbcms_meeting_presence WHERE meeting_id = :id")
                .bind("id", meetingId).then();
        return deleteOld.thenMany(Flux.fromIterable(presences)
                .flatMap(p -> client.sql("""
                                INSERT INTO bbcms_meeting_presence(meeting_id, member_id, visitor_id, present_at, role)
                                VALUES (:m, :mb, :v, :pa, :r)
                                """)
                        .bind("m", meetingId)
                        .bind("mb", p.getMemberId().orElse(null))
                        .bind("v", p.getVisitorId().orElse(null))
                        .bind("pa", p.getPresentAt())
                        .bind("r", p.getRole().name())
                        .then()))
                .then();
    }

    @Override
    public Mono<Long> countPicturesByMeeting(UUID meetingId) {
        return client.sql("SELECT COUNT(*) AS n FROM bbcms_meeting_picture WHERE meeting_id = :id")
                .bind("id", meetingId)
                .map((row, m) -> row.get("n", Long.class))
                .one();
    }

    @Override
    public Mono<Void> savePictures(UUID meetingId, List<MeetingPicture> pictures) {
        return Flux.fromIterable(pictures)
                .flatMap(p -> client.sql("""
                                INSERT INTO bbcms_meeting_picture(meeting_id, file_id, caption, taken_at)
                                VALUES (:m, :f, :c, :t)
                                """)
                        .bind("m", meetingId)
                        .bind("f", p.fileId())
                        .bind("c", p.caption() == null ? "" : p.caption())
                        .bind("t", p.takenAt())
                        .then())
                .then();
    }

    @Override
    public Mono<Long> countEligibleForMember(UUID memberId, UUID bibleClubId, UUID levelId,
                                             Iterable<String> departments, int academicYear) {
        // V1 simplifié: comptage des meetings RECORDED dans l'année académique qui auraient
        // dû concerner ce membre selon son BBC, son level, ses départements et son leadership.
        // ACADEMIC_MEETING est exclu (countsForFaithfulness=false).
        LocalDate yearStart = LocalDate.of(academicYear, 9, 1);
        LocalDate yearEnd = LocalDate.of(academicYear + 1, 8, 31);
        List<String> deps = new java.util.ArrayList<>();
        departments.forEach(deps::add);
        return client.sql("""
                SELECT COUNT(DISTINCT m.id) AS n
                FROM bbcms_meeting m
                LEFT JOIN bbcms_meeting_levels_concerned mlc ON mlc.meeting_id = m.id
                LEFT JOIN bbcms_meeting_bbc_concerned mbc ON mbc.meeting_id = m.id
                WHERE m.status = 'RECORDED'
                  AND m.type <> 'ACADEMIC_MEETING'
                  AND m.date_occurred BETWEEN :s AND :e
                  AND (
                       (m.type = 'CLASS_MEETING' AND m.level_id = :lvl)
                    OR (m.type = 'GENERAL_MEETING' AND m.bible_club_id = :bbc)
                    OR (m.type = 'JOINT_CLASS_MEETING' AND mlc.level_id = :lvl)
                    OR (m.type = 'JOINT_BBC_MEETING' AND mbc.bible_club_id = :bbc)
                    OR (m.type = 'DEPARTMENTAL_MEETING' AND m.department = ANY(:deps))
                    OR (m.type IN ('LEADERS_MEETING','SPIRITUAL_RETREAT','PRAYER_MEETING',
                                   'WELCOME_PARTY','CONFERENCE','FEAST') AND m.bible_club_id = :bbc)
                  )
                """)
                .bind("s", yearStart)
                .bind("e", yearEnd)
                .bind("lvl", levelId == null ? new UUID(0L, 0L) : levelId)
                .bind("bbc", bibleClubId == null ? new UUID(0L, 0L) : bibleClubId)
                .bind("deps", deps.isEmpty() ? new String[]{"__none__"} : deps.toArray(new String[0]))
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .defaultIfEmpty(0L);
    }

    private Mono<Meeting> toDomain(MeetingRow r) {
        Mono<HashSet<UUID>> levels = client.sql(
                        "SELECT level_id FROM bbcms_meeting_levels_concerned WHERE meeting_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("level_id", UUID.class))
                .all().collect(HashSet<UUID>::new, HashSet::add);
        Mono<HashSet<UUID>> bbcs = client.sql(
                        "SELECT bible_club_id FROM bbcms_meeting_bbc_concerned WHERE meeting_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("bible_club_id", UUID.class))
                .all().collect(HashSet<UUID>::new, HashSet::add);
        return Mono.zip(levels, bbcs).map(t -> Meeting.rehydrate(
                r.getId(), r.getBibleClubId(), r.getLevelId(),
                r.getDepartment() == null ? null : Department.valueOf(r.getDepartment()),
                t.getT1(), t.getT2(),
                r.getTitle(), MeetingType.valueOf(r.getType()),
                r.getPlannedDate(), r.getPlannedStartTime(), r.getPlannedEndTime(),
                r.getDateOccurred(), r.getStartTime(), r.getEndTime(),
                r.getDurationMinutes(), r.getTeacherMemberId(), r.getSummary(),
                r.getNbBelievers(), r.getMaxPictures(),
                MeetingStatus.valueOf(r.getStatus()),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()));
    }

    private MeetingRow toRow(Meeting m) {
        MeetingRow r = new MeetingRow();
        r.setId(m.getId());
        r.setBibleClubId(m.getBibleClubId().orElse(null));
        r.setLevelId(m.getLevelId().orElse(null));
        r.setDepartment(m.getDepartment().map(Enum::name).orElse(null));
        r.setTitle(m.getTitle());
        r.setType(m.getType().name());
        r.setPlannedDate(m.getPlannedDate());
        r.setPlannedStartTime(m.getPlannedStartTime());
        r.setPlannedEndTime(m.getPlannedEndTime());
        r.setDateOccurred(m.getDateOccurred());
        r.setStartTime(m.getStartTime());
        r.setEndTime(m.getEndTime());
        r.setDurationMinutes(m.getDurationMinutes());
        r.setTeacherMemberId(m.getTeacherMemberId().orElse(null));
        r.setSummary(m.getSummary());
        r.setNbBelievers(m.getNbBelievers());
        r.setMaxPictures(m.getMaxPictures());
        r.setStatus(m.getStatus().name());
        Instant now = Instant.now();
        if (m.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(m.getCreatedBy() == null ? SYSTEM : m.getCreatedBy());
            r.setCreatedAt(m.getCreatedAt() == null ? now : m.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(m.getVersion());
        return r;
    }
}
