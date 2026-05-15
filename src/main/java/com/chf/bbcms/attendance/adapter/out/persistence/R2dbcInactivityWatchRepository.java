package com.chf.bbcms.attendance.adapter.out.persistence;

import com.chf.bbcms.attendance.application.port.out.InactivityWatchRepository;
import com.chf.bbcms.attendance.domain.InactivityWatch;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcInactivityWatchRepository implements InactivityWatchRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcInactivityWatchRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<InactivityWatch> findByMember(UUID memberId) {
        return template.selectOne(Query.query(Criteria.where("member_id").is(memberId)),
                        InactivityWatchRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<InactivityWatch> findActive() {
        return template.select(InactivityWatchRow.class)
                .matching(Query.query(Criteria.where("removed_at").isNull()))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<InactivityWatch> save(InactivityWatch w) {
        InactivityWatchRow row = toRow(w);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private InactivityWatch toDomain(InactivityWatchRow r) {
        return InactivityWatch.rehydrate(r.getId(), r.getMemberId(), r.getLastSeenAt(),
                r.getConsecutiveAbsences(), r.getThresholdDays(), r.getRemovedAt());
    }

    private InactivityWatchRow toRow(InactivityWatch w) {
        InactivityWatchRow r = new InactivityWatchRow();
        r.setId(w.getId());
        r.setMemberId(w.getMemberId());
        r.setLastSeenAt(w.getLastSeenAt());
        r.setConsecutiveAbsences(w.getConsecutiveAbsences());
        r.setThresholdDays(w.getThresholdDays());
        r.setRemovedAt(w.getRemovedAt());
        return r;
    }
}
