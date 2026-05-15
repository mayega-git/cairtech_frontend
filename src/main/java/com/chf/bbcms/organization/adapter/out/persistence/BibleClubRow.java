package com.chf.bbcms.organization.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_bible_club")
public class BibleClubRow {
    @Id private UUID id;
    private String name;
    private String profile;
    @Column("school_name")          private String schoolName;
    @Column("goal_nb_faithful")     private Integer goalNbFaithful;
    @Column("date_created")         private LocalDate dateCreated;
    private String status;
    @Column("president_member_id")        private UUID presidentMemberId;
    @Column("vice_president_member_id")   private UUID vicePresidentMemberId;
    @Column("secretary_member_id")        private UUID secretaryMemberId;
    @Column("image_file_id")              private UUID imageFileId;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                 public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }           public void setName(String name) { this.name = name; }
    public String getProfile() { return profile; }     public void setProfile(String profile) { this.profile = profile; }
    public String getSchoolName() { return schoolName; }       public void setSchoolName(String s) { this.schoolName = s; }
    public Integer getGoalNbFaithful() { return goalNbFaithful; } public void setGoalNbFaithful(Integer g) { this.goalNbFaithful = g; }
    public LocalDate getDateCreated() { return dateCreated; }    public void setDateCreated(LocalDate d) { this.dateCreated = d; }
    public String getStatus() { return status; }       public void setStatus(String status) { this.status = status; }
    public UUID getPresidentMemberId() { return presidentMemberId; }     public void setPresidentMemberId(UUID i) { this.presidentMemberId = i; }
    public UUID getVicePresidentMemberId() { return vicePresidentMemberId; } public void setVicePresidentMemberId(UUID i) { this.vicePresidentMemberId = i; }
    public UUID getSecretaryMemberId() { return secretaryMemberId; }     public void setSecretaryMemberId(UUID i) { this.secretaryMemberId = i; }
    public UUID getImageFileId() { return imageFileId; }                 public void setImageFileId(UUID i) { this.imageFileId = i; }
    public UUID getCreatedBy() { return createdBy; }   public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }   public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }       public void setVersion(Long v) { this.version = v; }
}
