package com.chf.bbcms.discipleship.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Table("bbcms_discipleship_record")
public class DiscipleshipRecordRow {
    @Id private UUID id;
    @Column("disciple_maker_member_id") private UUID discipleMakerMemberId;
    @Column("meeting_id") private UUID meetingId;
    @Column("date_occurred") private LocalDate dateOccurred;
    @Column("start_time") private LocalTime startTime;
    @Column("end_time") private LocalTime endTime;
    private String theme;
    private String location;
    @Column("meeting_description") private String meetingDescription;
    @Column("disciples_state_text") private String disciplesStateText;
    @Column("spiritual_investment_text") private String spiritualInvestmentText;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getDiscipleMakerMemberId() { return discipleMakerMemberId; } public void setDiscipleMakerMemberId(UUID m) { this.discipleMakerMemberId = m; }
    public UUID getMeetingId() { return meetingId; } public void setMeetingId(UUID m) { this.meetingId = m; }
    public LocalDate getDateOccurred() { return dateOccurred; } public void setDateOccurred(LocalDate d) { this.dateOccurred = d; }
    public LocalTime getStartTime() { return startTime; } public void setStartTime(LocalTime t) { this.startTime = t; }
    public LocalTime getEndTime() { return endTime; } public void setEndTime(LocalTime t) { this.endTime = t; }
    public String getTheme() { return theme; } public void setTheme(String t) { this.theme = t; }
    public String getLocation() { return location; } public void setLocation(String l) { this.location = l; }
    public String getMeetingDescription() { return meetingDescription; } public void setMeetingDescription(String m) { this.meetingDescription = m; }
    public String getDisciplesStateText() { return disciplesStateText; } public void setDisciplesStateText(String d) { this.disciplesStateText = d; }
    public String getSpiritualInvestmentText() { return spiritualInvestmentText; } public void setSpiritualInvestmentText(String s) { this.spiritualInvestmentText = s; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; } public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; } public void setVersion(Long v) { this.version = v; }
}
