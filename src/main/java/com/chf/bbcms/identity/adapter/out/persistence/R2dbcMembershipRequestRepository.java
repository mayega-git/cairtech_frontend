package com.chf.bbcms.identity.adapter.out.persistence;

import com.chf.bbcms.identity.application.port.out.MembershipRequestRepository;
import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import com.chf.bbcms.identity.domain.UserType;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcMembershipRequestRepository implements MembershipRequestRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcMembershipRequestRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<MembershipRequest> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), MembershipRequestRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<MembershipRequest> findByStatus(MembershipRequestStatus status) {
        return template.select(MembershipRequestRow.class)
                .matching(Query.query(Criteria.where("status").is(status.name())))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<MembershipRequest> save(MembershipRequest r) {
        MembershipRequestRow row = toRow(r);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private MembershipRequest toDomain(MembershipRequestRow r) {
        return MembershipRequest.rehydrate(r.getId(), r.getUserAccountId(),
                UserType.valueOf(r.getRequestedType()),
                r.getBibleClubId(), r.getLevelId(), r.getProfession(),
                MembershipRequestStatus.valueOf(r.getStatus()),
                r.getDecisionBy(), r.getDecisionAt(), r.getDecisionComment(),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private MembershipRequestRow toRow(MembershipRequest m) {
        MembershipRequestRow r = new MembershipRequestRow();
        r.setId(m.getId());
        r.setUserAccountId(m.getUserAccountId());
        r.setRequestedType(m.getRequestedType().name());
        r.setBibleClubId(m.getBibleClubId().orElse(null));
        r.setLevelId(m.getLevelId().orElse(null));
        r.setProfession(m.getProfession());
        r.setStatus(m.getStatus().name());
        r.setDecisionBy(m.getDecisionBy());
        r.setDecisionAt(m.getDecisionAt());
        r.setDecisionComment(m.getDecisionComment());
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
