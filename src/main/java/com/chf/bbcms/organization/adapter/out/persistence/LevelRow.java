package com.chf.bbcms.organization.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_level")
public class LevelRow {
    @Id private UUID id;
    @Column("bible_club_id") private UUID bibleClubId;
    private String name;
    private String profile;
    private String type;
    @Column("president_member_id") private UUID presidentMemberId;
    @Column("vice_president_member_id") private UUID vicePresidentMemberId;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                  public void setId(UUID id) { this.id = id; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public String getName() { return name; }            public void setName(String n) { this.name = n; }
    public String getProfile() { return profile; }      public void setProfile(String p) { this.profile = p; }
    public String getType() { return type; }            public void setType(String t) { this.type = t; }
    public UUID getPresidentMemberId() { return presidentMemberId; }     public void setPresidentMemberId(UUID i) { this.presidentMemberId = i; }
    public UUID getVicePresidentMemberId() { return vicePresidentMemberId; } public void setVicePresidentMemberId(UUID i) { this.vicePresidentMemberId = i; }
    public UUID getCreatedBy() { return createdBy; }    public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }    public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }        public void setVersion(Long v) { this.version = v; }
}
