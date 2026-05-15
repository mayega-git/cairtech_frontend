package com.chf.bbcms.event.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_event")
public class EventRow {
    @Id private UUID id;
    private String title;
    private String type;
    @Column("planned_start_dt") private Instant plannedStartDt;
    @Column("planned_end_dt")   private Instant plannedEndDt;
    @Column("started_at")       private Instant startedAt;
    @Column("ended_at")         private Instant endedAt;
    @Column("duration_minutes") private Integer durationMinutes;
    private String location;
    @Column("max_pictures")     private int maxPictures;
    private String status;
    @Column("image_file_id")    private UUID imageFileId;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }              public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; }       public void setTitle(String t) { this.title = t; }
    public String getType() { return type; }         public void setType(String t) { this.type = t; }
    public Instant getPlannedStartDt() { return plannedStartDt; } public void setPlannedStartDt(Instant p) { this.plannedStartDt = p; }
    public Instant getPlannedEndDt() { return plannedEndDt; } public void setPlannedEndDt(Instant p) { this.plannedEndDt = p; }
    public Instant getStartedAt() { return startedAt; } public void setStartedAt(Instant s) { this.startedAt = s; }
    public Instant getEndedAt() { return endedAt; }  public void setEndedAt(Instant e) { this.endedAt = e; }
    public Integer getDurationMinutes() { return durationMinutes; } public void setDurationMinutes(Integer d) { this.durationMinutes = d; }
    public String getLocation() { return location; } public void setLocation(String l) { this.location = l; }
    public int getMaxPictures() { return maxPictures; } public void setMaxPictures(int m) { this.maxPictures = m; }
    public String getStatus() { return status; }     public void setStatus(String s) { this.status = s; }
    public UUID getImageFileId() { return imageFileId; } public void setImageFileId(UUID i) { this.imageFileId = i; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; } public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }     public void setVersion(Long v) { this.version = v; }
}
