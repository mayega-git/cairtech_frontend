package com.chf.bbcms.sync.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_sync_cursor")
public class SyncCursorRow {
    @Id private UUID id;
    @Column("user_account_id") private UUID userAccountId;
    @Column("device_id") private String deviceId;
    @Column("entity_kind") private String entityKind;
    @Column("last_synced_at") private Instant lastSyncedAt;
    @Column("updated_at") private Instant updatedAt;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getUserAccountId() { return userAccountId; } public void setUserAccountId(UUID u) { this.userAccountId = u; }
    public String getDeviceId() { return deviceId; } public void setDeviceId(String d) { this.deviceId = d; }
    public String getEntityKind() { return entityKind; } public void setEntityKind(String e) { this.entityKind = e; }
    public Instant getLastSyncedAt() { return lastSyncedAt; } public void setLastSyncedAt(Instant l) { this.lastSyncedAt = l; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
}
