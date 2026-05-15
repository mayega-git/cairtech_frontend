package com.chf.bbcms.publication.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_daily_verse_publication")
public class DailyVerseRow {
    @Id private UUID id;
    private String title;
    private String reference;
    @Column("verse_text") private String verseText;
    @Column("reflection_text") private String reflectionText;
    @Column("image_file_id") private UUID imageFileId;
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
    public String getReference() { return reference; } public void setReference(String r) { this.reference = r; }
    public String getVerseText() { return verseText; } public void setVerseText(String v) { this.verseText = v; }
    public String getReflectionText() { return reflectionText; } public void setReflectionText(String r) { this.reflectionText = r; }
    public UUID getImageFileId() { return imageFileId; } public void setImageFileId(UUID i) { this.imageFileId = i; }
    public LocalDate getPublishDate() { return publishDate; } public void setPublishDate(LocalDate p) { this.publishDate = p; }
    public String getStatus() { return status; } public void setStatus(String s) { this.status = s; }
    public String getAudience() { return audience; } public void setAudience(String a) { this.audience = a; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; } public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; } public void setVersion(Long v) { this.version = v; }
}
