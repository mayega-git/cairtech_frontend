package com.chf.bbcms.publication.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public class SpecialAnnouncement extends BaseEntity {

    private String title;
    private String content;
    private UUID imageFileId;
    private AnnouncementType type;
    private LocalDate publishDate;
    private PublicationStatus status;
    private PublicationAudience audience;

    protected SpecialAnnouncement() {}

    public static SpecialAnnouncement draft(String title, String content, UUID imageFileId,
                                            AnnouncementType type, LocalDate publishDate,
                                            PublicationAudience audience) {
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (content == null || content.isBlank()) throw new IllegalArgumentException("content required");
        if (type == null) throw new IllegalArgumentException("type required");
        if (publishDate == null) throw new IllegalArgumentException("publishDate required");
        SpecialAnnouncement a = new SpecialAnnouncement();
        a.title = title;
        a.content = content;
        a.imageFileId = imageFileId;
        a.type = type;
        a.publishDate = publishDate;
        a.status = PublicationStatus.DRAFT;
        a.audience = audience == null ? PublicationAudience.CHF : audience;
        return a;
    }

    public static SpecialAnnouncement rehydrate(UUID id, String title, String content, UUID imageFileId,
                                                AnnouncementType type, LocalDate publishDate,
                                                PublicationStatus status, PublicationAudience audience,
                                                Instant createdAt, Instant updatedAt, Long version) {
        SpecialAnnouncement a = new SpecialAnnouncement();
        a.id = id;
        a.title = title;
        a.content = content;
        a.imageFileId = imageFileId;
        a.type = type;
        a.publishDate = publishDate;
        a.status = status;
        a.audience = audience;
        a.createdAt = createdAt;
        a.updatedAt = updatedAt;
        a.version = version;
        return a;
    }

    public void publishNow() {
        if (status == PublicationStatus.PUBLISHED)
            throw new BusinessRuleViolation("BBCMS_PUB_TERMINAL", "Already PUBLISHED");
        this.status = PublicationStatus.PUBLISHED;
    }

    public String getTitle() { return title; }
    public String getContent() { return content; }
    public Optional<UUID> getImageFileId() { return Optional.ofNullable(imageFileId); }
    public AnnouncementType getType() { return type; }
    public LocalDate getPublishDate() { return publishDate; }
    public PublicationStatus getStatus() { return status; }
    public PublicationAudience getAudience() { return audience; }
}
