package com.chf.bbcms.attendance.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_inactivity_watch")
public class InactivityWatchRow {
    @Id private UUID id;
    @Column("member_id") private UUID memberId;
    @Column("last_seen_at") private Instant lastSeenAt;
    @Column("consecutive_absences") private int consecutiveAbsences;
    @Column("threshold_days") private int thresholdDays;
    @Column("removed_at") private Instant removedAt;

    public UUID getId() { return id; }                 public void setId(UUID id) { this.id = id; }
    public UUID getMemberId() { return memberId; }     public void setMemberId(UUID m) { this.memberId = m; }
    public Instant getLastSeenAt() { return lastSeenAt; } public void setLastSeenAt(Instant l) { this.lastSeenAt = l; }
    public int getConsecutiveAbsences() { return consecutiveAbsences; } public void setConsecutiveAbsences(int c) { this.consecutiveAbsences = c; }
    public int getThresholdDays() { return thresholdDays; } public void setThresholdDays(int t) { this.thresholdDays = t; }
    public Instant getRemovedAt() { return removedAt; } public void setRemovedAt(Instant r) { this.removedAt = r; }
}
