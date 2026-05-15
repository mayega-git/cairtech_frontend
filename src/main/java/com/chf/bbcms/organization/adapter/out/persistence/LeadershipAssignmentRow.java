package com.chf.bbcms.organization.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_leadership_assignment")
public class LeadershipAssignmentRow {
    @Id private UUID id;
    @Column("member_id")         private UUID memberId;
    private String position;
    @Column("scope_bible_club_id") private UUID scopeBibleClubId;
    @Column("scope_level_id")     private UUID scopeLevelId;
    @Column("date_start")         private LocalDate dateStart;
    @Column("date_end")           private LocalDate dateEnd;
    private boolean active;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                          public void setId(UUID id) { this.id = id; }
    public UUID getMemberId() { return memberId; }              public void setMemberId(UUID m) { this.memberId = m; }
    public String getPosition() { return position; }            public void setPosition(String p) { this.position = p; }
    public UUID getScopeBibleClubId() { return scopeBibleClubId; } public void setScopeBibleClubId(UUID s) { this.scopeBibleClubId = s; }
    public UUID getScopeLevelId() { return scopeLevelId; }      public void setScopeLevelId(UUID s) { this.scopeLevelId = s; }
    public LocalDate getDateStart() { return dateStart; }       public void setDateStart(LocalDate d) { this.dateStart = d; }
    public LocalDate getDateEnd() { return dateEnd; }           public void setDateEnd(LocalDate d) { this.dateEnd = d; }
    public boolean isActive() { return active; }                public void setActive(boolean a) { this.active = a; }
    public UUID getCreatedBy() { return createdBy; }            public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; }         public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }            public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; }         public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }                public void setVersion(Long v) { this.version = v; }
}
