package com.chf.bbcms.publication.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_special_announcement")
public class SpecialAnnouncementRow {
    @Id private UUID id;
    private String title;
    private String content;
    @Column("image_file_id") private UUID imageFileId;
    private String type;
    @Column("publish_date") private LocalDate publishDate;
    private String status;
    private String audience;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; } public void setTitle(String t) { this.title = t; }
    public String getContent() { return content; } public void setContent(String c) { this.content = c; }
    public UUID getImageFileId() { return imageFileId; } public void setImageFileId(UUID i) { this.imageFileId = i; }
    public String getType() { return type; } public void setType(String t) { this.type = t; }
    public LocalDate getPublishDate() { return publishDate; } public void setPublishDate(LocalDate p) { this.publishDate = p; }
    public String getStatus() { return status; } public void setStatus(String s) { this.status = s; }
    public String getAudience() { return audience; } public void setAudience(String a) { this.audience = a; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; } public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; } public void setVersion(Long v) { this.version = v; }
}
