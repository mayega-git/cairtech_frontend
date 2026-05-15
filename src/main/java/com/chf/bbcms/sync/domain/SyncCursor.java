package com.chf.bbcms.sync.domain;

import java.time.Instant;
import java.util.UUID;

/**
 * Curseur par utilisateur+device+entité, mémorise le dernier updated_at synchronisé.
 * Permet à un client offline de reprendre une sync incrémentale.
 */
public record SyncCursor(
        UUID id,
        UUID userAccountId,
        String deviceId,
        SyncEntityKind entityKind,
        Instant lastSyncedAt,
        Instant updatedAt
) {
    public static SyncCursor initial(UUID userAccountId, String deviceId, SyncEntityKind kind) {
        return new SyncCursor(null, userAccountId, deviceId, kind, Instant.EPOCH, Instant.now());
    }

    public SyncCursor advance(Instant to) {
        return new SyncCursor(id, userAccountId, deviceId, entityKind, to, Instant.now());
    }
}
