package com.chf.bbcms.event.adapter.out.persistence;

import com.chf.bbcms.event.application.port.out.EventRepository;
import com.chf.bbcms.event.domain.Event;
import com.chf.bbcms.event.domain.EventParticipation;
import com.chf.bbcms.event.domain.EventStatus;
import com.chf.bbcms.event.domain.EventType;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;

@Repository
public class R2dbcEventRepository implements EventRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcEventRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<Event> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), EventRow.class).map(this::toDomain);
    }

    @Override
    public Flux<Event> findAll() { return template.select(EventRow.class).all().map(this::toDomain); }

    @Override
    public Mono<Event> save(Event e) {
        EventRow row = toRow(e);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Flux<EventParticipation> findParticipations(UUID eventId) {
        return client.sql("SELECT * FROM bbcms_event_participation WHERE event_id = :id")
                .bind("id", eventId)
                .map((row, m) -> mapParticipation(row))
                .all();
    }

    @Override
    public Mono<EventParticipation> findParticipation(UUID eventId, UUID memberId) {
        return client.sql("SELECT * FROM bbcms_event_participation WHERE event_id = :e AND member_id = :m")
                .bind("e", eventId).bind("m", memberId)
                .map((row, m) -> mapParticipation(row))
                .one();
    }

    @Override
    public Mono<EventParticipation> saveParticipation(EventParticipation p) {
        if (p.getId() == null) {
            return client.sql("""
                    INSERT INTO bbcms_event_participation(event_id, member_id, visitor_id, registered_at, present, present_at)
                    VALUES (:e, :m, :v, :r, :p, :pa)
                    RETURNING id
                    """)
                    .bind("e", p.getEventId())
                    .bind("m", p.getMemberId().orElse(null))
                    .bind("v", p.getVisitorId().orElse(null))
                    .bind("r", p.getRegisteredAt())
                    .bind("p", p.isPresent())
                    .bind("pa", p.getPresentAt())
                    .map((row, m) -> row.get("id", UUID.class))
                    .one()
                    .map(id -> EventParticipation.rehydrate(id, p.getEventId(), p.getMemberId().orElse(null),
                            p.getVisitorId().orElse(null), p.getRegisteredAt(), p.isPresent(), p.getPresentAt()));
        }
        return client.sql("""
                UPDATE bbcms_event_participation
                SET present = :p, present_at = :pa
                WHERE id = :id
                """)
                .bind("p", p.isPresent())
                .bind("pa", p.getPresentAt())
                .bind("id", p.getId())
                .then()
                .thenReturn(p);
    }

    @Override
    public Mono<Long> countAttendedByMember(UUID memberId, int academicYear) {
        Instant start = LocalDate.of(academicYear, 9, 1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant end = LocalDate.of(academicYear + 1, 8, 31).atTime(23, 59).toInstant(ZoneOffset.UTC);
        return client.sql("""
                SELECT COUNT(*) AS n
                FROM bbcms_event_participation
                WHERE member_id = :m AND present = true
                  AND present_at BETWEEN :s AND :e
                """)
                .bind("m", memberId).bind("s", start).bind("e", end)
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .defaultIfEmpty(0L);
    }

    private EventParticipation mapParticipation(io.r2dbc.spi.Row row) {
        return EventParticipation.rehydrate(
                row.get("id", UUID.class), row.get("event_id", UUID.class),
                row.get("member_id", UUID.class), row.get("visitor_id", UUID.class),
                row.get("registered_at", Instant.class),
                Boolean.TRUE.equals(row.get("present", Boolean.class)),
                row.get("present_at", Instant.class));
    }

    private Event toDomain(EventRow r) {
        return Event.rehydrate(r.getId(), r.getTitle(), EventType.valueOf(r.getType()),
                r.getPlannedStartDt(), r.getPlannedEndDt(), r.getStartedAt(), r.getEndedAt(),
                r.getDurationMinutes(), r.getLocation(), r.getMaxPictures(),
                EventStatus.valueOf(r.getStatus()), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private EventRow toRow(Event e) {
        EventRow r = new EventRow();
        r.setId(e.getId());
        r.setTitle(e.getTitle());
        r.setType(e.getType().name());
        r.setPlannedStartDt(e.getPlannedStartDt());
        r.setPlannedEndDt(e.getPlannedEndDt());
        r.setStartedAt(e.getStartedAt());
        r.setEndedAt(e.getEndedAt());
        r.setDurationMinutes(e.getDurationMinutes());
        r.setLocation(e.getLocation());
        r.setMaxPictures(e.getMaxPictures());
        r.setStatus(e.getStatus().name());
        Instant now = Instant.now();
        if (e.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(e.getCreatedBy() == null ? SYSTEM : e.getCreatedBy());
            r.setCreatedAt(e.getCreatedAt() == null ? now : e.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(e.getVersion());
        return r;
    }
}
