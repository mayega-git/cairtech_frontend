package com.chf.bbcms.finance.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_contribution_line")
public class ContributionLineRow {
    @Id private UUID id;
    @Column("contribution_id") private UUID contributionId;
    @Column("contributor_member_id") private UUID contributorMemberId;
    @Column("contributor_name") private String contributorName;
    private BigDecimal amount;
    @Column("payment_channel") private String paymentChannel;
    @Column("payment_reference") private String paymentReference;
    @Column("payment_date") private LocalDate paymentDate;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getContributionId() { return contributionId; } public void setContributionId(UUID c) { this.contributionId = c; }
    public UUID getContributorMemberId() { return contributorMemberId; } public void setContributorMemberId(UUID m) { this.contributorMemberId = m; }
    public String getContributorName() { return contributorName; } public void setContributorName(String n) { this.contributorName = n; }
    public BigDecimal getAmount() { return amount; } public void setAmount(BigDecimal a) { this.amount = a; }
    public String getPaymentChannel() { return paymentChannel; } public void setPaymentChannel(String p) { this.paymentChannel = p; }
    public String getPaymentReference() { return paymentReference; } public void setPaymentReference(String p) { this.paymentReference = p; }
    public LocalDate getPaymentDate() { return paymentDate; } public void setPaymentDate(LocalDate p) { this.paymentDate = p; }
}
