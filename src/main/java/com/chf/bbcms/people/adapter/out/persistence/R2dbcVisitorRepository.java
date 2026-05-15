package com.chf.bbcms.people.adapter.out.persistence;

import com.chf.bbcms.people.application.port.out.VisitorRepository;
import com.chf.bbcms.people.domain.Visitor;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcVisitorRepository implements VisitorRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcVisitorRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<Visitor> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), VisitorRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<Visitor> findByMeeting(UUID meetingId) {
        return template.select(VisitorRow.class)
                .matching(Query.query(Criteria.where("meeting_id").is(meetingId)))
                .all().map(this::toDomain);
    }

    @Override
    public Flux<Visitor> findByEvent(UUID eventId) {
        return template.select(VisitorRow.class)
                .matching(Query.query(Criteria.where("event_id").is(eventId)))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<Visitor> save(Visitor v) {
        VisitorRow row = toRow(v);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private Visitor toDomain(VisitorRow r) {
        return Visitor.rehydrate(r.getId(), r.getFirstNames(), r.getNextNames(),
                r.getPhoneNumber(), r.getMeetingId(), r.getEventId(), r.getVisitDate(),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private VisitorRow toRow(Visitor v) {
        VisitorRow r = new VisitorRow();
        r.setId(v.getId());
        r.setFirstNames(v.getFirstNames());
        r.setNextNames(v.getNextNames());
        r.setPhoneNumber(v.getPhoneNumber());
        r.setMeetingId(v.getMeetingId().orElse(null));
        r.setEventId(v.getEventId().orElse(null));
        r.setVisitDate(v.getVisitDate());
        Instant now = Instant.now();
        if (v.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(v.getCreatedBy() == null ? SYSTEM : v.getCreatedBy());
            r.setCreatedAt(v.getCreatedAt() == null ? now : v.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(v.getVersion());
        return r;
    }
}
