package com.chf.bbcms.attendance.domain;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.UUID;

/**
 * Score annuel de participation pour un membre.
 * Calcul: P% = score / total_eligible × 100  (RM-01).
 */
public class AttendanceScore {

    private UUID id;
    private UUID memberId;
    private UUID bibleClubId;
    private UUID levelId;
    private int academicYear;
    private int score;
    private int totalEligible;
    private BigDecimal faithfulPercentage;
    private boolean faithful;
    private Instant lastComputedAt;

    protected AttendanceScore() {}

    public static AttendanceScore initial(UUID memberId, UUID bibleClubId, UUID levelId, int academicYear) {
        AttendanceScore s = new AttendanceScore();
        s.memberId = memberId;
        s.bibleClubId = bibleClubId;
        s.levelId = levelId;
        s.academicYear = academicYear;
        s.score = 0;
        s.totalEligible = 0;
        s.faithfulPercentage = BigDecimal.ZERO;
        s.faithful = false;
        return s;
    }

    public static AttendanceScore rehydrate(UUID id, UUID memberId, UUID bibleClubId, UUID levelId,
                                            int academicYear, int score, int totalEligible,
                                            BigDecimal faithfulPercentage, boolean faithful,
                                            Instant lastComputedAt) {
        AttendanceScore s = new AttendanceScore();
        s.id = id;
        s.memberId = memberId;
        s.bibleClubId = bibleClubId;
        s.levelId = levelId;
        s.academicYear = academicYear;
        s.score = score;
        s.totalEligible = totalEligible;
        s.faithfulPercentage = faithfulPercentage == null ? BigDecimal.ZERO : faithfulPercentage;
        s.faithful = faithful;
        s.lastComputedAt = lastComputedAt;
        return s;
    }

    public void incrementBy(int weight) {
        if (weight < 0) throw new IllegalArgumentException("weight must be >= 0");
        this.score += weight;
    }

    /**
     * Recalcule le pourcentage et le flag faithful selon le seuil donné.
     * Si totalEligible == 0, faithful = false (UNDER_EVALUATION).
     */
    public void recompute(int totalEligible, BigDecimal thresholdPercentage) {
        this.totalEligible = totalEligible;
        if (totalEligible <= 0) {
            this.faithfulPercentage = BigDecimal.ZERO;
            this.faithful = false;
        } else {
            BigDecimal pct = BigDecimal.valueOf(score)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(totalEligible), 2, RoundingMode.HALF_UP);
            this.faithfulPercentage = pct;
            this.faithful = pct.compareTo(thresholdPercentage) >= 0;
        }
        this.lastComputedAt = Instant.now();
    }

    public void resetForNewYear() {
        this.score = 0;
        this.totalEligible = 0;
        this.faithfulPercentage = BigDecimal.ZERO;
        this.faithful = false;
    }

    public UUID getId() { return id; }
    public UUID getMemberId() { return memberId; }
    public UUID getBibleClubId() { return bibleClubId; }
    public UUID getLevelId() { return levelId; }
    public int getAcademicYear() { return academicYear; }
    public int getScore() { return score; }
    public int getTotalEligible() { return totalEligible; }
    public BigDecimal getFaithfulPercentage() { return faithfulPercentage; }
    public boolean isFaithful() { return faithful; }
    public Instant getLastComputedAt() { return lastComputedAt; }
}
