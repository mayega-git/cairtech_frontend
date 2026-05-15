package com.chf.bbcms.intercession.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.LocalDate;
import java.util.UUID;

public class PrayerChain {

    private UUID id;
    private UUID bibleClubId;
    private String title;
    private LocalDate dateStart;
    private LocalDate dateEnd;
    private PrayerChainStatus status;

    protected PrayerChain() {}

    public static PrayerChain draft(UUID bibleClubId, String title, LocalDate dateStart, LocalDate dateEnd) {
        if (bibleClubId == null) throw new IllegalArgumentException("bibleClubId required");
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (dateStart == null) throw new IllegalArgumentException("dateStart required");
        PrayerChain c = new PrayerChain();
        c.bibleClubId = bibleClubId;
        c.title = title;
        c.dateStart = dateStart;
        c.dateEnd = dateEnd;
        c.status = PrayerChainStatus.DRAFT;
        return c;
    }

    public static PrayerChain rehydrate(UUID id, UUID bibleClubId, String title,
                                        LocalDate dateStart, LocalDate dateEnd, PrayerChainStatus status) {
        PrayerChain c = new PrayerChain();
        c.id = id;
        c.bibleClubId = bibleClubId;
        c.title = title;
        c.dateStart = dateStart;
        c.dateEnd = dateEnd;
        c.status = status;
        return c;
    }

    public void start() {
        if (status != PrayerChainStatus.DRAFT)
            throw new BusinessRuleViolation("BBCMS_PC_BAD_STATE", "Only DRAFT can be started");
        this.status = PrayerChainStatus.RUNNING;
    }

    public void close() {
        if (status == PrayerChainStatus.CLOSED)
            throw new BusinessRuleViolation("BBCMS_PC_TERMINAL", "Already CLOSED");
        this.status = PrayerChainStatus.CLOSED;
    }

    public UUID getId() { return id; }
    public UUID getBibleClubId() { return bibleClubId; }
    public String getTitle() { return title; }
    public LocalDate getDateStart() { return dateStart; }
    public LocalDate getDateEnd() { return dateEnd; }
    public PrayerChainStatus getStatus() { return status; }
}
