package com.chf.bbcms.authentication.adapter.out.persistence;

import com.chf.bbcms.authentication.application.port.out.ActivationTokenRepository;
import com.chf.bbcms.authentication.domain.ActivationToken;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public class R2dbcActivationTokenRepository implements ActivationTokenRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcActivationTokenRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<ActivationToken> save(ActivationToken token) {
        ActivationTokenRow row = toRow(token);
        Mono<ActivationTokenRow> saved = row.getId() == null
                ? template.insert(row)
                : template.update(row);
        return saved.map(this::toDomain);
    }

    @Override
    public Mono<ActivationToken> findByToken(String token) {
        return template.selectOne(Query.query(Criteria.where("token").is(token)), ActivationTokenRow.class)
                .map(this::toDomain);
    }

    private ActivationTokenRow toRow(ActivationToken t) {
        ActivationTokenRow r = new ActivationTokenRow();
        r.setId(t.getId());
        r.setUserAccountId(t.getUserAccountId());
        r.setToken(t.getToken());
        r.setExpiresAt(t.getExpiresAt());
        r.setUsed(t.isUsed());
        return r;
    }

    private ActivationToken toDomain(ActivationTokenRow r) {
        return ActivationToken.rehydrate(r.getId(), r.getUserAccountId(), r.getToken(),
                r.getExpiresAt(), r.isUsed());
    }
}
