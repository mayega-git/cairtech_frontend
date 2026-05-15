package com.chf.bbcms.sync.adapter.out.persistence;

import com.chf.bbcms.sync.application.port.out.SyncCursorRepository;
import com.chf.bbcms.sync.domain.SyncCursor;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcSyncCursorRepository implements SyncCursorRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcSyncCursorRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<SyncCursor> find(UUID userAccountId, String deviceId, SyncEntityKind kind) {
        return template.selectOne(Query.query(
                        Criteria.where("user_account_id").is(userAccountId)
                                .and("device_id").is(deviceId)
                                .and("entity_kind").is(kind.name())),
                        SyncCursorRow.class)
                .map(this::toDomain);
    }

    @Override
    public Mono<SyncCursor> save(SyncCursor c) {
        SyncCursorRow row = new SyncCursorRow();
        row.setId(c.id());
        row.setUserAccountId(c.userAccountId());
        row.setDeviceId(c.deviceId());
        row.setEntityKind(c.entityKind().name());
        row.setLastSyncedAt(c.lastSyncedAt());
        row.setUpdatedAt(Instant.now());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private SyncCursor toDomain(SyncCursorRow r) {
        return new SyncCursor(r.getId(), r.getUserAccountId(), r.getDeviceId(),
                SyncEntityKind.valueOf(r.getEntityKind()),
                r.getLastSyncedAt(), r.getUpdatedAt());
    }
}
