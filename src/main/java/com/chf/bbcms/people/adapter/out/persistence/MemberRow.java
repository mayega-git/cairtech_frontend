package com.chf.bbcms.people.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Table("bbcms_member")
public class MemberRow {
    @Id private UUID id;
    @Column("user_account_id") private UUID userAccountId;
    @Column("member_kind")     private String memberKind;
    @Column("bible_club_id")   private UUID bibleClubId;
    @Column("level_id")        private UUID levelId;
    @Column("participation_score")  private int participationScore;
    @Column("faithful_percentage")  private BigDecimal faithfulPercentage;
    private String profession;
    @Column("professional_position") private String professionalPosition;
    private String status;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                  public void setId(UUID id) { this.id = id; }
    public UUID getUserAccountId() { return userAccountId; } public void setUserAccountId(UUID u) { this.userAccountId = u; }
    public String getMemberKind() { return memberKind; } public void setMemberKind(String k) { this.memberKind = k; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public UUID getLevelId() { return levelId; }        public void setLevelId(UUID l) { this.levelId = l; }
    public int getParticipationScore() { return participationScore; } public void setParticipationScore(int s) { this.participationScore = s; }
    public BigDecimal getFaithfulPercentage() { return faithfulPercentage; } public void setFaithfulPercentage(BigDecimal f) { this.faithfulPercentage = f; }
    public String getProfession() { return profession; } public void setProfession(String p) { this.profession = p; }
    public String getProfessionalPosition() { return professionalPosition; } public void setProfessionalPosition(String p) { this.professionalPosition = p; }
    public String getStatus() { return status; }        public void setStatus(String s) { this.status = s; }
    public UUID getCreatedBy() { return createdBy; }    public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }    public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }        public void setVersion(Long v) { this.version = v; }
}
