package com.chf.bbcms.organization.adapter.out.persistence;

import com.chf.bbcms.organization.application.port.out.LevelRepository;
import com.chf.bbcms.organization.domain.Level;
import com.chf.bbcms.organization.domain.LevelType;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcLevelRepository implements LevelRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcLevelRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<Level> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), LevelRow.class).map(this::toDomain);
    }

    @Override
    public Flux<Level> findByBibleClubId(UUID bibleClubId) {
        return template.select(LevelRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<Level> save(Level level) {
        LevelRow row = toRow(level);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<Void> deleteById(UUID id) {
        return template.delete(Query.query(Criteria.where("id").is(id)), LevelRow.class).then();
    }

    private Level toDomain(LevelRow r) {
        return Level.rehydrate(r.getId(), r.getBibleClubId(), r.getName(), r.getProfile(),
                LevelType.valueOf(r.getType()), r.getPresidentMemberId(), r.getVicePresidentMemberId(),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private LevelRow toRow(Level l) {
        LevelRow r = new LevelRow();
        r.setId(l.getId());
        r.setBibleClubId(l.getBibleClubId());
        r.setName(l.getName());
        r.setProfile(l.getProfile());
        r.setType(l.getType().name());
        r.setPresidentMemberId(l.getPresidentMemberId());
        r.setVicePresidentMemberId(l.getVicePresidentMemberId());
        Instant now = Instant.now();
        if (l.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(l.getCreatedBy() == null ? SYSTEM : l.getCreatedBy());
            r.setCreatedAt(l.getCreatedAt() == null ? now : l.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(l.getVersion());
        return r;
    }
}
