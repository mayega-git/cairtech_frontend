package com.chf.bbcms.attendance.domain;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

/**
 * Suivi d'inactivité d'un membre. Permet la transition ACTIVE → INACTIVE (>30j)
 * et la désinscription automatique (>90j) — RM-03.
 */
public class InactivityWatch {

    private UUID id;
    private UUID memberId;
    private Instant lastSeenAt;
    private int consecutiveAbsences;
    private int thresholdDays;
    private Instant removedAt;

    protected InactivityWatch() {}

    public static InactivityWatch initial(UUID memberId, int thresholdDays) {
        InactivityWatch w = new InactivityWatch();
        w.memberId = memberId;
        w.thresholdDays = thresholdDays;
        w.consecutiveAbsences = 0;
        return w;
    }

    public static InactivityWatch rehydrate(UUID id, UUID memberId, Instant lastSeenAt,
                                            int consecutiveAbsences, int thresholdDays, Instant removedAt) {
        InactivityWatch w = new InactivityWatch();
        w.id = id;
        w.memberId = memberId;
        w.lastSeenAt = lastSeenAt;
        w.consecutiveAbsences = consecutiveAbsences;
        w.thresholdDays = thresholdDays;
        w.removedAt = removedAt;
        return w;
    }

    public void recordPresence(Instant when) {
        this.lastSeenAt = when == null ? Instant.now() : when;
        this.consecutiveAbsences = 0;
    }

    public void incrementAbsence() { this.consecutiveAbsences++; }

    public boolean shouldBeRemoved(Instant now) {
        if (lastSeenAt == null) return false;
        if (removedAt != null) return false;
        return Duration.between(lastSeenAt, now).toDays() > thresholdDays;
    }

    public boolean shouldBeMarkedInactive(Instant now, int warningDays) {
        if (lastSeenAt == null) return false;
        if (removedAt != null) return false;
        return Duration.between(lastSeenAt, now).toDays() > warningDays;
    }

    public void markRemoved(Instant when) { this.removedAt = when == null ? Instant.now() : when; }

    public UUID getId() { return id; }
    public UUID getMemberId() { return memberId; }
    public Instant getLastSeenAt() { return lastSeenAt; }
    public int getConsecutiveAbsences() { return consecutiveAbsences; }
    public int getThresholdDays() { return thresholdDays; }
    public Instant getRemovedAt() { return removedAt; }
}
