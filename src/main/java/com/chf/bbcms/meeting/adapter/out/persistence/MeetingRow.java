package com.chf.bbcms.meeting.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Table("bbcms_meeting")
public class MeetingRow {
    @Id private UUID id;
    @Column("bible_club_id") private UUID bibleClubId;
    @Column("level_id")      private UUID levelId;
    private String department;
    private String title;
    private String type;
    @Column("planned_date")        private LocalDate plannedDate;
    @Column("planned_start_time")  private LocalTime plannedStartTime;
    @Column("planned_end_time")    private LocalTime plannedEndTime;
    @Column("date_occurred")       private LocalDate dateOccurred;
    @Column("start_time")          private LocalTime startTime;
    @Column("end_time")            private LocalTime endTime;
    @Column("duration_minutes")    private Integer durationMinutes;
    @Column("teacher_member_id")   private UUID teacherMemberId;
    private String summary;
    @Column("nb_believers")        private int nbBelievers;
    @Column("max_pictures")        private int maxPictures;
    private String status;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                        public void setId(UUID id) { this.id = id; }
    public UUID getBibleClubId() { return bibleClubId; }       public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public UUID getLevelId() { return levelId; }               public void setLevelId(UUID l) { this.levelId = l; }
    public String getDepartment() { return department; }       public void setDepartment(String d) { this.department = d; }
    public String getTitle() { return title; }                 public void setTitle(String t) { this.title = t; }
    public String getType() { return type; }                   public void setType(String t) { this.type = t; }
    public LocalDate getPlannedDate() { return plannedDate; }  public void setPlannedDate(LocalDate d) { this.plannedDate = d; }
    public LocalTime getPlannedStartTime() { return plannedStartTime; } public void setPlannedStartTime(LocalTime t) { this.plannedStartTime = t; }
    public LocalTime getPlannedEndTime() { return plannedEndTime; }     public void setPlannedEndTime(LocalTime t) { this.plannedEndTime = t; }
    public LocalDate getDateOccurred() { return dateOccurred; } public void setDateOccurred(LocalDate d) { this.dateOccurred = d; }
    public LocalTime getStartTime() { return startTime; }      public void setStartTime(LocalTime t) { this.startTime = t; }
    public LocalTime getEndTime() { return endTime; }          public void setEndTime(LocalTime t) { this.endTime = t; }
    public Integer getDurationMinutes() { return durationMinutes; } public void setDurationMinutes(Integer d) { this.durationMinutes = d; }
    public UUID getTeacherMemberId() { return teacherMemberId; } public void setTeacherMemberId(UUID t) { this.teacherMemberId = t; }
    public String getSummary() { return summary; }             public void setSummary(String s) { this.summary = s; }
    public int getNbBelievers() { return nbBelievers; }        public void setNbBelievers(int n) { this.nbBelievers = n; }
    public int getMaxPictures() { return maxPictures; }        public void setMaxPictures(int n) { this.maxPictures = n; }
    public String getStatus() { return status; }               public void setStatus(String s) { this.status = s; }
    public UUID getCreatedBy() { return createdBy; }           public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; }        public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }           public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; }        public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }               public void setVersion(Long v) { this.version = v; }
}
