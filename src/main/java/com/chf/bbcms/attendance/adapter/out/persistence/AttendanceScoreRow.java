package com.chf.bbcms.attendance.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Table("bbcms_attendance_score")
public class AttendanceScoreRow {
    @Id private UUID id;
    @Column("member_id") private UUID memberId;
    @Column("bible_club_id") private UUID bibleClubId;
    @Column("level_id") private UUID levelId;
    @Column("academic_year") private int academicYear;
    private int score;
    @Column("total_eligible") private int totalEligible;
    @Column("faithful_percentage") private BigDecimal faithfulPercentage;
    private boolean faithful;
    @Column("last_computed_at") private Instant lastComputedAt;

    public UUID getId() { return id; }                public void setId(UUID id) { this.id = id; }
    public UUID getMemberId() { return memberId; }    public void setMemberId(UUID m) { this.memberId = m; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public UUID getLevelId() { return levelId; }      public void setLevelId(UUID l) { this.levelId = l; }
    public int getAcademicYear() { return academicYear; } public void setAcademicYear(int y) { this.academicYear = y; }
    public int getScore() { return score; }           public void setScore(int s) { this.score = s; }
    public int getTotalEligible() { return totalEligible; } public void setTotalEligible(int t) { this.totalEligible = t; }
    public BigDecimal getFaithfulPercentage() { return faithfulPercentage; } public void setFaithfulPercentage(BigDecimal f) { this.faithfulPercentage = f; }
    public boolean isFaithful() { return faithful; }  public void setFaithful(boolean f) { this.faithful = f; }
    public Instant getLastComputedAt() { return lastComputedAt; } public void setLastComputedAt(Instant l) { this.lastComputedAt = l; }
}
