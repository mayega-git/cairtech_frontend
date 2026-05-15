package com.chf.bbcms.publication.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public class DailyVersePublication extends BaseEntity {

    private String title;
    private String reference;
    private String verseText;
    private String reflectionText;
    private UUID imageFileId;
    private LocalDate publishDate;
    private PublicationStatus status;
    private PublicationAudience audience;

    protected DailyVersePublication() {}

    public static DailyVersePublication draft(String title, String reference, String verseText,
                                              String reflectionText, UUID imageFileId,
                                              LocalDate publishDate, PublicationAudience audience) {
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (reference == null || reference.isBlank()) throw new IllegalArgumentException("reference required");
        if (verseText == null || verseText.isBlank()) throw new IllegalArgumentException("verseText required");
        if (publishDate == null) throw new IllegalArgumentException("publishDate required");
        DailyVersePublication p = new DailyVersePublication();
        p.title = title;
        p.reference = reference;
        p.verseText = verseText;
        p.reflectionText = reflectionText;
        p.imageFileId = imageFileId;
        p.publishDate = publishDate;
        p.status = PublicationStatus.DRAFT;
        p.audience = audience == null ? PublicationAudience.CHF : audience;
        return p;
    }

    public static DailyVersePublication rehydrate(UUID id, String title, String reference, String verseText,
                                                  String reflectionText, UUID imageFileId,
                                                  LocalDate publishDate, PublicationStatus status,
                                                  PublicationAudience audience, Instant createdAt,
                                                  Instant updatedAt, Long version) {
        DailyVersePublication p = new DailyVersePublication();
        p.id = id;
        p.title = title;
        p.reference = reference;
        p.verseText = verseText;
        p.reflectionText = reflectionText;
        p.imageFileId = imageFileId;
        p.publishDate = publishDate;
        p.status = status;
        p.audience = audience;
        p.createdAt = createdAt;
        p.updatedAt = updatedAt;
        p.version = version;
        return p;
    }

    public void schedule() {
        if (status != PublicationStatus.DRAFT)
            throw new BusinessRuleViolation("BBCMS_PUB_BAD_STATE", "Only DRAFT can be scheduled");
        this.status = PublicationStatus.SCHEDULED;
    }

    public void publishNow() {
        if (status == PublicationStatus.PUBLISHED)
            throw new BusinessRuleViolation("BBCMS_PUB_TERMINAL", "Already PUBLISHED");
        this.status = PublicationStatus.PUBLISHED;
    }

    public String getTitle() { return title; }
    public String getReference() { return reference; }
    public String getVerseText() { return verseText; }
    public String getReflectionText() { return reflectionText; }
    public Optional<UUID> getImageFileId() { return Optional.ofNullable(imageFileId); }
    public LocalDate getPublishDate() { return publishDate; }
    public PublicationStatus getStatus() { return status; }
    public PublicationAudience getAudience() { return audience; }
}
