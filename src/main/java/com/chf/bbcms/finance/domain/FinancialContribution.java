package com.chf.bbcms.finance.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

/**
 * V1: devise unique XAF (validé). On expose currency en lecture mais on bloque
 * toute valeur autre que XAF à la création.
 */
public class FinancialContribution {

    private static final String DEFAULT_CURRENCY = "XAF";

    private UUID id;
    private UUID bibleClubId;
    private String title;
    private String description;
    private BigDecimal objectiveAmount;
    private String currency;
    private LocalDate dateOpen;
    private LocalDate dateClose;
    private ContributionStatus status;
    private BigDecimal totalContributed;

    protected FinancialContribution() {}

    public static FinancialContribution open(UUID bibleClubId, String title, String description,
                                             BigDecimal objectiveAmount, LocalDate dateOpen) {
        if (bibleClubId == null) throw new IllegalArgumentException("bibleClubId required");
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (objectiveAmount == null || objectiveAmount.signum() < 0)
            throw new IllegalArgumentException("objectiveAmount must be >= 0");
        FinancialContribution c = new FinancialContribution();
        c.bibleClubId = bibleClubId;
        c.title = title;
        c.description = description;
        c.objectiveAmount = objectiveAmount;
        c.currency = DEFAULT_CURRENCY;
        c.dateOpen = dateOpen == null ? LocalDate.now() : dateOpen;
        c.status = ContributionStatus.OPEN;
        c.totalContributed = BigDecimal.ZERO;
        return c;
    }

    public static FinancialContribution rehydrate(UUID id, UUID bibleClubId, String title, String description,
                                                  BigDecimal objectiveAmount, String currency,
                                                  LocalDate dateOpen, LocalDate dateClose,
                                                  ContributionStatus status, BigDecimal totalContributed) {
        FinancialContribution c = new FinancialContribution();
        c.id = id;
        c.bibleClubId = bibleClubId;
        c.title = title;
        c.description = description;
        c.objectiveAmount = objectiveAmount;
        c.currency = currency;
        c.dateOpen = dateOpen;
        c.dateClose = dateClose;
        c.status = status;
        c.totalContributed = totalContributed == null ? BigDecimal.ZERO : totalContributed;
        return c;
    }

    public void close(LocalDate when) {
        if (status == ContributionStatus.CLOSED)
            throw new BusinessRuleViolation("BBCMS_CONTRIB_TERMINAL", "Already CLOSED");
        this.status = ContributionStatus.CLOSED;
        this.dateClose = when == null ? LocalDate.now() : when;
    }

    public void addAmount(BigDecimal amount) {
        if (status != ContributionStatus.OPEN)
            throw new BusinessRuleViolation("BBCMS_CONTRIB_NOT_OPEN",
                    "Cannot add to a non-OPEN contribution");
        if (amount == null || amount.signum() <= 0)
            throw new IllegalArgumentException("amount must be > 0");
        this.totalContributed = this.totalContributed.add(amount);
    }

    public boolean objectiveReached() {
        return totalContributed.compareTo(objectiveAmount) >= 0;
    }

    public double percentageReached() {
        if (objectiveAmount.signum() == 0) return 0d;
        return totalContributed.multiply(BigDecimal.valueOf(100))
                .divide(objectiveAmount, 2, java.math.RoundingMode.HALF_UP).doubleValue();
    }

    public UUID getId() { return id; }
    public UUID getBibleClubId() { return bibleClubId; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public BigDecimal getObjectiveAmount() { return objectiveAmount; }
    public String getCurrency() { return currency; }
    public LocalDate getDateOpen() { return dateOpen; }
    public LocalDate getDateClose() { return dateClose; }
    public ContributionStatus getStatus() { return status; }
    public BigDecimal getTotalContributed() { return totalContributed; }
}
