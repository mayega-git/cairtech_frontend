package com.chf.bbcms.attendance.adapter.out.persistence;

import com.chf.bbcms.attendance.application.port.out.AttendanceScoreRepository;
import com.chf.bbcms.attendance.domain.AttendanceScore;
import com.chf.bbcms.attendance.domain.FaithfulnessRecord;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcAttendanceScoreRepository implements AttendanceScoreRepository {

    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcAttendanceScoreRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<AttendanceScore> findByMemberAndYear(UUID memberId, int academicYear) {
        return template.selectOne(Query.query(
                        Criteria.where("member_id").is(memberId).and("academic_year").is(academicYear)),
                        AttendanceScoreRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<AttendanceScore> findByBibleClubAndYear(UUID bibleClubId, int academicYear) {
        return template.select(AttendanceScoreRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)
                        .and("academic_year").is(academicYear)))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<AttendanceScore> save(AttendanceScore s) {
        AttendanceScoreRow row = toRow(s);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<Void> resetByBibleClubAndYear(UUID bibleClubId, int academicYear) {
        return client.sql("""
                UPDATE bbcms_attendance_score
                SET score = 0, faithful = false, faithful_percentage = 0
                WHERE bible_club_id = :b AND academic_year = :y
                """)
                .bind("b", bibleClubId).bind("y", academicYear)
                .then();
    }

    @Override
    public Mono<Boolean> tryAddRecord(FaithfulnessRecord r) {
        return client.sql("""
                INSERT INTO bbcms_faithfulness_record(attendance_score_id, member_id, meeting_id, event_id,
                                                     evangelism_record_id, source, counted_at, weight)
                VALUES (:s, :m, :mt, :ev, :evr, :src, :c, :w)
                ON CONFLICT (member_id, source, meeting_id, event_id, evangelism_record_id) DO NOTHING
                RETURNING id
                """)
                .bind("s", r.attendanceScoreId())
                .bind("m", r.memberId())
                .bind("mt", r.meetingId() == null ? null : r.meetingId())
                .bind("ev", r.eventId() == null ? null : r.eventId())
                .bind("evr", r.evangelismRecordId() == null ? null : r.evangelismRecordId())
                .bind("src", r.source().name())
                .bind("c", r.countedAt())
                .bind("w", r.weight())
                .map((row, m) -> row.get("id", UUID.class))
                .one()
                .map(id -> true)
                .defaultIfEmpty(false);
    }

    private AttendanceScore toDomain(AttendanceScoreRow r) {
        return AttendanceScore.rehydrate(r.getId(), r.getMemberId(), r.getBibleClubId(), r.getLevelId(),
                r.getAcademicYear(), r.getScore(), r.getTotalEligible(),
                r.getFaithfulPercentage(), r.isFaithful(), r.getLastComputedAt());
    }

    private AttendanceScoreRow toRow(AttendanceScore s) {
        AttendanceScoreRow r = new AttendanceScoreRow();
        r.setId(s.getId());
        r.setMemberId(s.getMemberId());
        r.setBibleClubId(s.getBibleClubId());
        r.setLevelId(s.getLevelId());
        r.setAcademicYear(s.getAcademicYear());
        r.setScore(s.getScore());
        r.setTotalEligible(s.getTotalEligible());
        r.setFaithfulPercentage(s.getFaithfulPercentage());
        r.setFaithful(s.isFaithful());
        r.setLastComputedAt(s.getLastComputedAt());
        return r;
    }
}
