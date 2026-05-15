package com.chf.bbcms.intercession.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public class PrayerSlot {

    private UUID id;
    private UUID prayerChainId;
    private UUID intercessorMemberId;
    private Instant dtStart;
    private Instant dtEnd;
    private boolean covered;
    private String note;

    protected PrayerSlot() {}

    public static PrayerSlot create(UUID prayerChainId, Instant start, Instant end) {
        if (prayerChainId == null) throw new IllegalArgumentException("prayerChainId required");
        if (start == null || end == null) throw new IllegalArgumentException("start/end required");
        if (!end.isAfter(start)) throw new IllegalArgumentException("end must be after start");
        PrayerSlot s = new PrayerSlot();
        s.prayerChainId = prayerChainId;
        s.dtStart = start;
        s.dtEnd = end;
        s.covered = false;
        return s;
    }

    public static PrayerSlot rehydrate(UUID id, UUID prayerChainId, UUID intercessorMemberId,
                                       Instant start, Instant end, boolean covered, String note) {
        PrayerSlot s = new PrayerSlot();
        s.id = id;
        s.prayerChainId = prayerChainId;
        s.intercessorMemberId = intercessorMemberId;
        s.dtStart = start;
        s.dtEnd = end;
        s.covered = covered;
        s.note = note;
        return s;
    }

    public void cover(UUID intercessorMemberId, String note) {
        if (covered)
            throw new BusinessRuleViolation("BBCMS_SLOT_ALREADY_COVERED",
                    "Slot already covered by another intercessor");
        if (intercessorMemberId == null)
            throw new IllegalArgumentException("intercessorMemberId required");
        this.intercessorMemberId = intercessorMemberId;
        this.covered = true;
        this.note = note;
    }

    public void uncover() {
        this.covered = false;
        this.intercessorMemberId = null;
    }

    public UUID getId() { return id; }
    public UUID getPrayerChainId() { return prayerChainId; }
    public Optional<UUID> getIntercessorMemberId() { return Optional.ofNullable(intercessorMemberId); }
    public Instant getDtStart() { return dtStart; }
    public Instant getDtEnd() { return dtEnd; }
    public boolean isCovered() { return covered; }
    public String getNote() { return note; }
}
