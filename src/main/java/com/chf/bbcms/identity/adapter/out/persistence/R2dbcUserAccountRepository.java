package com.chf.bbcms.identity.adapter.out.persistence;

import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.UserAccount;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcUserAccountRepository implements UserAccountRepository {

    private final R2dbcEntityTemplate template;

    @Autowired
    public R2dbcUserAccountRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<UserAccount> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), UserAccountRow.class)
                .map(UserAccountMapper::toDomain);
    }

    @Override
    public Mono<UserAccount> findByEmail(String email) {
        return template.selectOne(Query.query(Criteria.where("email").is(email.toLowerCase())), UserAccountRow.class)
                .map(UserAccountMapper::toDomain);
    }

    @Override
    public Mono<Boolean> existsByEmail(String email) {
        return template.exists(Query.query(Criteria.where("email").is(email.toLowerCase())), UserAccountRow.class);
    }

    @Override
    public Mono<UserAccount> save(UserAccount account) {
        UserAccountRow row = UserAccountMapper.toRow(account, null);
        if (row.getId() == null) {
            return template.insert(row).map(UserAccountMapper::toDomain);
        }
        return template.update(row).map(UserAccountMapper::toDomain);
    }
}
