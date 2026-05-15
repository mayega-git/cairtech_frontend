package com.chf.bbcms.sync.domain;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * Représente un changement remonté par le serveur vers un client offline.
 * payload est la sérialisation JSON de la ligne SQL (clé = nom de colonne).
 */
public record SyncChange(
        UUID id,
        SyncEntityKind kind,
        Instant updatedAt,
        long version,
        Map<String, Object> payload
) {}
