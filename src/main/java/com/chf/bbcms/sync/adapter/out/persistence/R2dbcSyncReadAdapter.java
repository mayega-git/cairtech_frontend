package com.chf.bbcms.sync.adapter.out.persistence;

import com.chf.bbcms.sync.application.port.out.SyncReadPort;
import com.chf.bbcms.sync.domain.SyncChange;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import io.r2dbc.spi.ColumnMetadata;
import io.r2dbc.spi.Row;
import io.r2dbc.spi.RowMetadata;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Lecture générique des changements via SELECT * FROM <table> WHERE updated_at > :since.
 * Le payload est une Map nom-colonne → valeur (sérialisable en JSON par Jackson).
 *
 * Note: pour l'attendance_score (pas de colonne updated_at) on utilise last_computed_at.
 */
@Component
public class R2dbcSyncReadAdapter implements SyncReadPort {

    private final DatabaseClient client;

    public R2dbcSyncReadAdapter(DatabaseClient client) {
        this.client = client;
    }

    @Override
    public Flux<SyncChange> findChangesSince(SyncEntityKind kind, Instant since, int limit) {
        String timestampColumn = timestampColumnFor(kind);
        String sql = """
                SELECT * FROM %s
                 WHERE %s > :since
                 ORDER BY %s ASC
                 LIMIT :lim
                """.formatted(kind.tableName(), timestampColumn, timestampColumn);
        return client.sql(sql)
                .bind("since", since)
                .bind("lim", limit)
                .map((row, meta) -> mapToChange(kind, row, meta, timestampColumn))
                .all();
    }

    private SyncChange mapToChange(SyncEntityKind kind, Row row, RowMetadata meta, String tsCol) {
        Map<String, Object> payload = new LinkedHashMap<>();
        UUID id = null;
        Instant updatedAt = Instant.EPOCH;
        long version = 0L;
        for (ColumnMetadata col : meta.getColumnMetadatas()) {
            String name = col.getName();
            Object value = row.get(name);
            payload.put(name, value);
            if ("id".equals(name) && value instanceof UUID u) id = u;
            if (tsCol.equals(name) && value instanceof Instant i) updatedAt = i;
            if ("version".equals(name) && value instanceof Number n) version = n.longValue();
        }
        return new SyncChange(id, kind, updatedAt, version, payload);
    }

    private String timestampColumnFor(SyncEntityKind kind) {
        return switch (kind) {
            case ATTENDANCE_SCORE -> "last_computed_at";
            default -> "updated_at";
        };
    }
}
