package com.chf.bbcms.shared.domain;

import java.time.Instant;
import java.util.UUID;

/**
 * Racine d'audit héritée par toutes les tables bbcms_*.
 * version est un verrou optimiste géré par Spring Data R2DBC via @Version.
 */
public abstract class BaseEntity {

    protected UUID id;
    protected UUID createdBy;
    protected Instant createdAt;
    protected UUID updatedBy;
    protected Instant updatedAt;
    protected Long version;

    protected BaseEntity() {}

    public UUID getId() { return id; }
    public UUID getCreatedBy() { return createdBy; }
    public Instant getCreatedAt() { return createdAt; }
    public UUID getUpdatedBy() { return updatedBy; }
    public Instant getUpdatedAt() { return updatedAt; }
    public Long getVersion() { return version; }
}
