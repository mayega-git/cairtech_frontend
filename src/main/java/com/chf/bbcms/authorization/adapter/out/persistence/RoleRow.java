package com.chf.bbcms.authorization.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_role")
public class RoleRow {
    @Id
    private UUID id;
    private String name;
    private String description;
    @Column("created_by")  private UUID createdBy;
    @Column("created_at")  private Instant createdAt;
    @Column("updated_by")  private UUID updatedBy;
    @Column("updated_at")  private Instant updatedAt;
    @Version               private Long version;

    public UUID getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public Long getVersion() { return version; }
}
