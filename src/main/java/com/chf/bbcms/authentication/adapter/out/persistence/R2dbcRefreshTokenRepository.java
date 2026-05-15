package com.chf.bbcms.authentication.adapter.out.persistence;

import com.chf.bbcms.authentication.application.port.out.RefreshTokenRepository;
import com.chf.bbcms.authentication.domain.RefreshToken;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public class R2dbcRefreshTokenRepository implements RefreshTokenRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcRefreshTokenRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<RefreshToken> save(RefreshToken token) {
        RefreshTokenRow row = new RefreshTokenRow();
        row.setId(token.getId());
        row.setUserAccountId(token.getUserAccountId());
        row.setTokenHash(token.getTokenHash());
        row.setExpiresAt(token.getExpiresAt());
        row.setRevoked(token.isRevoked());
        row.setCreatedAt(token.getCreatedAt());
        Mono<RefreshTokenRow> saved = row.getId() == null ? template.insert(row) : template.update(row);
        return saved.map(this::toDomain);
    }

    @Override
    public Mono<RefreshToken> findByHash(String tokenHash) {
        return template.selectOne(Query.query(Criteria.where("token_hash").is(tokenHash)),
                        RefreshTokenRow.class)
                .map(this::toDomain);
    }

    private RefreshToken toDomain(RefreshTokenRow r) {
        return RefreshToken.rehydrate(r.getId(), r.getUserAccountId(), r.getTokenHash(),
                r.getExpiresAt(), r.isRevoked(), r.getCreatedAt());
    }
}
