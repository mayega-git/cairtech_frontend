package com.chf.bbcms.authentication.adapter.out.persistence;

import com.chf.bbcms.authentication.application.port.out.PasswordResetTokenRepository;
import com.chf.bbcms.authentication.domain.PasswordResetToken;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public class R2dbcPasswordResetTokenRepository implements PasswordResetTokenRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcPasswordResetTokenRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<PasswordResetToken> save(PasswordResetToken token) {
        PasswordResetTokenRow row = toRow(token);
        Mono<PasswordResetTokenRow> saved = row.getId() == null
                ? template.insert(row)
                : template.update(row);
        return saved.map(this::toDomain);
    }

    @Override
    public Mono<PasswordResetToken> findByToken(String token) {
        return template.selectOne(
                        Query.query(Criteria.where("token").is(token)),
                        PasswordResetTokenRow.class)
                .map(this::toDomain);
    }

    private PasswordResetTokenRow toRow(PasswordResetToken t) {
        PasswordResetTokenRow r = new PasswordResetTokenRow();
        r.setId(t.getId());
        r.setUserAccountId(t.getUserAccountId());
        r.setToken(t.getToken());
        r.setExpiresAt(t.getExpiresAt());
        r.setUsed(t.isUsed());
        return r;
    }

    private PasswordResetToken toDomain(PasswordResetTokenRow r) {
        return PasswordResetToken.rehydrate(r.getId(), r.getUserAccountId(), r.getToken(),
                r.getExpiresAt(), r.isUsed());
    }
}
