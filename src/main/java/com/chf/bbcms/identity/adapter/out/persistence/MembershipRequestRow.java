package com.chf.bbcms.identity.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_membership_request")
public class MembershipRequestRow {
    @Id private UUID id;
    @Column("user_account_id") private UUID userAccountId;
    @Column("requested_type")  private String requestedType;
    @Column("bible_club_id")   private UUID bibleClubId;
    @Column("level_id")        private UUID levelId;
    private String profession;
    private String status;
    @Column("decision_by")      private UUID decisionBy;
    @Column("decision_at")      private Instant decisionAt;
    @Column("decision_comment") private String decisionComment;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                      public void setId(UUID id) { this.id = id; }
    public UUID getUserAccountId() { return userAccountId; } public void setUserAccountId(UUID u) { this.userAccountId = u; }
    public String getRequestedType() { return requestedType; } public void setRequestedType(String r) { this.requestedType = r; }
    public UUID getBibleClubId() { return bibleClubId; }    public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public UUID getLevelId() { return levelId; }            public void setLevelId(UUID l) { this.levelId = l; }
    public String getProfession() { return profession; }    public void setProfession(String p) { this.profession = p; }
    public String getStatus() { return status; }            public void setStatus(String s) { this.status = s; }
    public UUID getDecisionBy() { return decisionBy; }      public void setDecisionBy(UUID d) { this.decisionBy = d; }
    public Instant getDecisionAt() { return decisionAt; }   public void setDecisionAt(Instant d) { this.decisionAt = d; }
    public String getDecisionComment() { return decisionComment; } public void setDecisionComment(String d) { this.decisionComment = d; }
    public UUID getCreatedBy() { return createdBy; }        public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; }     public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }        public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; }     public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }            public void setVersion(Long v) { this.version = v; }
}
