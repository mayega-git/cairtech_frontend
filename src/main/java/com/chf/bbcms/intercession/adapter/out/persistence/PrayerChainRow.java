package com.chf.bbcms.intercession.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_prayer_chain")
public class PrayerChainRow {
    @Id private UUID id;
    @Column("bible_club_id") private UUID bibleClubId;
    private String title;
    @Column("date_start") private LocalDate dateStart;
    @Column("date_end") private LocalDate dateEnd;
    private String status;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public String getTitle() { return title; } public void setTitle(String t) { this.title = t; }
    public LocalDate getDateStart() { return dateStart; } public void setDateStart(LocalDate d) { this.dateStart = d; }
    public LocalDate getDateEnd() { return dateEnd; } public void setDateEnd(LocalDate d) { this.dateEnd = d; }
    public String getStatus() { return status; } public void setStatus(String s) { this.status = s; }
}
