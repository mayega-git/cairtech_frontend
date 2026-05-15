package com.chf.bbcms.finance.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public class ContributionLine {

    private UUID id;
    private UUID contributionId;
    private UUID contributorMemberId;
    private String contributorName;
    private BigDecimal amount;
    private PaymentChannel paymentChannel;
    private String paymentReference;
    private LocalDate paymentDate;

    protected ContributionLine() {}

    public static ContributionLine record(UUID contributionId, UUID memberId, String name,
                                          BigDecimal amount, PaymentChannel channel,
                                          String reference, LocalDate paymentDate) {
        if (contributionId == null) throw new IllegalArgumentException("contributionId required");
        if (memberId == null && (name == null || name.isBlank()))
            throw new BusinessRuleViolation("BBCMS_CONTRIB_NO_CONTRIBUTOR",
                    "Either contributorMemberId or contributorName must be provided");
        if (amount == null || amount.signum() <= 0)
            throw new IllegalArgumentException("amount must be > 0");
        if (channel == null) throw new IllegalArgumentException("paymentChannel required");
        ContributionLine l = new ContributionLine();
        l.contributionId = contributionId;
        l.contributorMemberId = memberId;
        l.contributorName = name;
        l.amount = amount;
        l.paymentChannel = channel;
        l.paymentReference = reference;
        l.paymentDate = paymentDate == null ? LocalDate.now() : paymentDate;
        return l;
    }

    public static ContributionLine rehydrate(UUID id, UUID contributionId, UUID memberId, String name,
                                             BigDecimal amount, PaymentChannel channel,
                                             String reference, LocalDate paymentDate) {
        ContributionLine l = new ContributionLine();
        l.id = id;
        l.contributionId = contributionId;
        l.contributorMemberId = memberId;
        l.contributorName = name;
        l.amount = amount;
        l.paymentChannel = channel;
        l.paymentReference = reference;
        l.paymentDate = paymentDate;
        return l;
    }

    public UUID getId() { return id; }
    public UUID getContributionId() { return contributionId; }
    public Optional<UUID> getContributorMemberId() { return Optional.ofNullable(contributorMemberId); }
    public String getContributorName() { return contributorName; }
    public BigDecimal getAmount() { return amount; }
    public PaymentChannel getPaymentChannel() { return paymentChannel; }
    public String getPaymentReference() { return paymentReference; }
    public LocalDate getPaymentDate() { return paymentDate; }
}
