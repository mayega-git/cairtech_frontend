package com.chf.bbcms.people.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_visitor")
public class VisitorRow {
    @Id private UUID id;
    @Column("first_names") private String firstNames;
    @Column("next_names")  private String nextNames;
    @Column("phone_number") private String phoneNumber;
    @Column("meeting_id")  private UUID meetingId;
    @Column("event_id")    private UUID eventId;
    @Column("visit_date")  private LocalDate visitDate;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                  public void setId(UUID id) { this.id = id; }
    public String getFirstNames() { return firstNames; } public void setFirstNames(String f) { this.firstNames = f; }
    public String getNextNames() { return nextNames; }   public void setNextNames(String n) { this.nextNames = n; }
    public String getPhoneNumber() { return phoneNumber; } public void setPhoneNumber(String p) { this.phoneNumber = p; }
    public UUID getMeetingId() { return meetingId; }    public void setMeetingId(UUID m) { this.meetingId = m; }
    public UUID getEventId() { return eventId; }        public void setEventId(UUID e) { this.eventId = e; }
    public LocalDate getVisitDate() { return visitDate; } public void setVisitDate(LocalDate v) { this.visitDate = v; }
    public UUID getCreatedBy() { return createdBy; }    public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }    public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }        public void setVersion(Long v) { this.version = v; }
}
