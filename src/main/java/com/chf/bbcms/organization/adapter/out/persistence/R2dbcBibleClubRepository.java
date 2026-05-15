package com.chf.bbcms.organization.adapter.out.persistence;

import com.chf.bbcms.organization.application.port.out.BibleClubRepository;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.organization.domain.BibleClubStatus;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcBibleClubRepository implements BibleClubRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcBibleClubRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<BibleClub> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), BibleClubRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<BibleClub> findAll() {
        return template.select(BibleClubRow.class).all().map(this::toDomain);
    }

    @Override
    public Mono<BibleClub> save(BibleClub b) {
        BibleClubRow row = toRow(b);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<Void> deleteById(UUID id) {
        return template.delete(Query.query(Criteria.where("id").is(id)), BibleClubRow.class).then();
    }

    private BibleClub toDomain(BibleClubRow r) {
        return BibleClub.rehydrate(r.getId(), r.getName(), r.getProfile(), r.getSchoolName(),
                r.getGoalNbFaithful(), r.getDateCreated(),
                BibleClubStatus.valueOf(r.getStatus()),
                r.getPresidentMemberId(), r.getVicePresidentMemberId(), r.getSecretaryMemberId(),
                r.getImageFileId(),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private BibleClubRow toRow(BibleClub b) {
        BibleClubRow r = new BibleClubRow();
        r.setId(b.getId());
        r.setName(b.getName());
        r.setProfile(b.getProfile());
        r.setSchoolName(b.getSchoolName());
        r.setGoalNbFaithful(b.getGoalNbFaithful());
        r.setDateCreated(b.getDateCreated());
        r.setStatus(b.getStatus().name());
        r.setPresidentMemberId(b.getPresidentMemberId());
        r.setVicePresidentMemberId(b.getVicePresidentMemberId());
        r.setSecretaryMemberId(b.getSecretaryMemberId());
        r.setImageFileId(b.getImageFileId());
        Instant now = Instant.now();
        if (b.getId() == null) {
            r.setCreatedBy(SYSTEM);
            r.setCreatedAt(now);
        } else {
            r.setCreatedBy(b.getCreatedBy() == null ? SYSTEM : b.getCreatedBy());
            r.setCreatedAt(b.getCreatedAt() == null ? now : b.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM);
        r.setUpdatedAt(now);
        r.setVersion(b.getVersion());
        return r;
    }
}
