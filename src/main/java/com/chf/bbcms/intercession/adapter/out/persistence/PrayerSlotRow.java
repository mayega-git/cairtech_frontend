package com.chf.bbcms.intercession.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_prayer_slot")
public class PrayerSlotRow {
    @Id private UUID id;
    @Column("prayer_chain_id") private UUID prayerChainId;
    @Column("intercessor_member_id") private UUID intercessorMemberId;
    @Column("dt_start") private Instant dtStart;
    @Column("dt_end") private Instant dtEnd;
    private boolean covered;
    private String note;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getPrayerChainId() { return prayerChainId; } public void setPrayerChainId(UUID p) { this.prayerChainId = p; }
    public UUID getIntercessorMemberId() { return intercessorMemberId; } public void setIntercessorMemberId(UUID i) { this.intercessorMemberId = i; }
    public Instant getDtStart() { return dtStart; } public void setDtStart(Instant d) { this.dtStart = d; }
    public Instant getDtEnd() { return dtEnd; } public void setDtEnd(Instant d) { this.dtEnd = d; }
    public boolean isCovered() { return covered; } public void setCovered(boolean c) { this.covered = c; }
    public String getNote() { return note; } public void setNote(String n) { this.note = n; }
}
