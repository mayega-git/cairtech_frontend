package com.chf.bbcms.shared.outbox;

import io.r2dbc.postgresql.codec.Json;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

/**
 * Entry persistée dans `bbcms_domain_event` (outbox transactionnelle).
 * `payload_json` est de type PostgreSQL JSONB ; on utilise le type natif
 * R2DBC `io.r2dbc.postgresql.codec.Json` côté Java pour permettre au driver
 * d'effectuer le binding correct.
 */
@Table("bbcms_domain_event")
public class OutboxEntry {

    @Id
    private UUID id;

    @Column("type")
    private String type;

    @Column("aggregate_id")
    private UUID aggregateId;

    @Column("payload_json")
    private Json payloadJson;

    @Column("created_at")
    private Instant createdAt;

    @Column("processed")
    private boolean processed;

    @Column("processed_at")
    private Instant processedAt;

    @Column("attempts")
    private int attempts;

    @Column("last_error")
    private String lastError;

    public static OutboxEntry create(String type, UUID aggregateId, String payloadJson) {
        OutboxEntry e = new OutboxEntry();
        e.type = type;
        e.aggregateId = aggregateId;
        e.payloadJson = Json.of(payloadJson);
        e.createdAt = Instant.now();
        e.processed = false;
        e.attempts = 0;
        return e;
    }

    public UUID getId() { return id; }
    public String getType() { return type; }
    public UUID getAggregateId() { return aggregateId; }
    public String getPayloadJson() {
        return payloadJson == null ? null : payloadJson.asString();
    }
    public Instant getCreatedAt() { return createdAt; }
    public boolean isProcessed() { return processed; }
    public Instant getProcessedAt() { return processedAt; }
    public int getAttempts() { return attempts; }
    public String getLastError() { return lastError; }

    public void markProcessed() {
        this.processed = true;
        this.processedAt = Instant.now();
    }

    public void markFailed(String error) {
        this.attempts++;
        this.lastError = error;
    }
}
