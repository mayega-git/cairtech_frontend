package com.chf.bbcms.finance.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_financial_contribution")
public class FinancialContributionRow {
    @Id private UUID id;
    @Column("bible_club_id") private UUID bibleClubId;
    private String title;
    private String description;
    @Column("objective_amount") private BigDecimal objectiveAmount;
    private String currency;
    @Column("date_open") private LocalDate dateOpen;
    @Column("date_close") private LocalDate dateClose;
    private String status;
    @Column("total_contributed") private BigDecimal totalContributed;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public String getTitle() { return title; } public void setTitle(String t) { this.title = t; }
    public String getDescription() { return description; } public void setDescription(String d) { this.description = d; }
    public BigDecimal getObjectiveAmount() { return objectiveAmount; } public void setObjectiveAmount(BigDecimal o) { this.objectiveAmount = o; }
    public String getCurrency() { return currency; } public void setCurrency(String c) { this.currency = c; }
    public LocalDate getDateOpen() { return dateOpen; } public void setDateOpen(LocalDate d) { this.dateOpen = d; }
    public LocalDate getDateClose() { return dateClose; } public void setDateClose(LocalDate d) { this.dateClose = d; }
    public String getStatus() { return status; } public void setStatus(String s) { this.status = s; }
    public BigDecimal getTotalContributed() { return totalContributed; } public void setTotalContributed(BigDecimal t) { this.totalContributed = t; }
}
