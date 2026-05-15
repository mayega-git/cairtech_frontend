package com.chf.bbcms.discipleship.adapter.out.persistence;

import com.chf.bbcms.discipleship.application.port.out.DiscipleLinkRepository;
import com.chf.bbcms.discipleship.domain.DiscipleLink;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcDiscipleLinkRepository implements DiscipleLinkRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcDiscipleLinkRepository(R2dbcEntityTemplate template) { this.template = template; }

    @Override
    public Mono<DiscipleLink> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), DiscipleLinkRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<DiscipleLink> findActiveByMaker(UUID makerId) {
        return template.select(DiscipleLinkRow.class)
                .matching(Query.query(Criteria.where("disciple_maker_member_id").is(makerId)
                        .and("active").isTrue()))
                .all().map(this::toDomain);
    }

    @Override
    public Flux<DiscipleLink> findActiveByDisciple(UUID discipleId) {
        return template.select(DiscipleLinkRow.class)
                .matching(Query.query(Criteria.where("disciple_member_id").is(discipleId)
                        .and("active").isTrue()))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<DiscipleLink> save(DiscipleLink l) {
        DiscipleLinkRow row = new DiscipleLinkRow();
        row.setId(l.getId());
        row.setDiscipleMakerMemberId(l.getDiscipleMakerMemberId());
        row.setDiscipleMemberId(l.getDiscipleMemberId());
        row.setDateAssigned(l.getDateAssigned());
        row.setDateEnded(l.getDateEnded());
        row.setActive(l.isActive());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private DiscipleLink toDomain(DiscipleLinkRow r) {
        return DiscipleLink.rehydrate(r.getId(), r.getDiscipleMakerMemberId(), r.getDiscipleMemberId(),
                r.getDateAssigned(), r.getDateEnded(), r.isActive());
    }
}
