package com.chf.bbcms.organization.adapter.out.persistence;

import com.chf.bbcms.organization.application.port.out.LeadershipAssignmentRepository;
import com.chf.bbcms.organization.domain.LeadershipAssignment;
import com.chf.bbcms.organization.domain.LeadershipPosition;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcLeadershipAssignmentRepository implements LeadershipAssignmentRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcLeadershipAssignmentRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<LeadershipAssignment> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), LeadershipAssignmentRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<LeadershipAssignment> findActiveByMember(UUID memberId) {
        return template.select(LeadershipAssignmentRow.class)
                .matching(Query.query(Criteria.where("member_id").is(memberId).and("active").isTrue()))
                .all().map(this::toDomain);
    }

    @Override
    public Flux<LeadershipAssignment> findActiveByBibleClub(UUID bibleClubId) {
        return template.select(LeadershipAssignmentRow.class)
                .matching(Query.query(Criteria.where("scope_bible_club_id").is(bibleClubId).and("active").isTrue()))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<LeadershipAssignment> save(LeadershipAssignment la) {
        LeadershipAssignmentRow r = toRow(la);
        return (r.getId() == null ? template.insert(r) : template.update(r)).map(this::toDomain);
    }

    private LeadershipAssignment toDomain(LeadershipAssignmentRow r) {
        return LeadershipAssignment.rehydrate(r.getId(), r.getMemberId(),
                LeadershipPosition.valueOf(r.getPosition()),
                r.getScopeBibleClubId(), r.getScopeLevelId(),
                r.getDateStart(), r.getDateEnd(), r.isActive(),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private LeadershipAssignmentRow toRow(LeadershipAssignment la) {
        LeadershipAssignmentRow r = new LeadershipAssignmentRow();
        r.setId(la.getId());
        r.setMemberId(la.getMemberId());
        r.setPosition(la.getPosition().name());
        r.setScopeBibleClubId(la.getScopeBibleClubId().orElse(null));
        r.setScopeLevelId(la.getScopeLevelId().orElse(null));
        r.setDateStart(la.getDateStart());
        r.setDateEnd(la.getDateEnd());
        r.setActive(la.isActive());
        Instant now = Instant.now();
        if (la.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(la.getCreatedBy() == null ? SYSTEM : la.getCreatedBy());
            r.setCreatedAt(la.getCreatedAt() == null ? now : la.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(la.getVersion());
        return r;
    }
}
