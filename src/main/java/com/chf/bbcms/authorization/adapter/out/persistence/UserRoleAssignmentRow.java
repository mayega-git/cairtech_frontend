package com.chf.bbcms.authorization.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_user_role_assignment")
public class UserRoleAssignmentRow {
    @Id
    private UUID id;
    @Column("user_account_id")     private UUID userAccountId;
    @Column("role_id")             private UUID roleId;
    @Column("scope_bible_club_id") private UUID scopeBibleClubId;
    private boolean active;
    @Column("created_by")          private UUID createdBy;
    @Column("created_at")          private Instant createdAt;
    @Column("updated_by")          private UUID updatedBy;
    @Column("updated_at")          private Instant updatedAt;
    @Version                       private Long version;

    public UUID getId() { return id; }
    public UUID getUserAccountId() { return userAccountId; }
    public UUID getRoleId() { return roleId; }
    public UUID getScopeBibleClubId() { return scopeBibleClubId; }
    public boolean isActive() { return active; }
    public Long getVersion() { return version; }
}
