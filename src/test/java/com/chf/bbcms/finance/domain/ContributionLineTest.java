package com.chf.bbcms.finance.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class ContributionLineTest {

    @Test
    void requires_member_or_name() {
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> ContributionLine.record(UUID.randomUUID(), null, null,
                        BigDecimal.TEN, PaymentChannel.CASH, null, null));
        assertEquals("BBCMS_CONTRIB_NO_CONTRIBUTOR", ex.getCode());
    }

    @Test
    void member_contribution_works() {
        ContributionLine l = ContributionLine.record(UUID.randomUUID(), UUID.randomUUID(), null,
                BigDecimal.valueOf(5000), PaymentChannel.MTN_MOMO, "TX-123", null);
        assertEquals(PaymentChannel.MTN_MOMO, l.getPaymentChannel());
        assertEquals("TX-123", l.getPaymentReference());
        assertNotNull(l.getPaymentDate());
    }

    @Test
    void external_contribution_with_name_works() {
        ContributionLine l = ContributionLine.record(UUID.randomUUID(), null, "M. Dupont",
                BigDecimal.valueOf(10000), PaymentChannel.CASH, null, null);
        assertEquals("M. Dupont", l.getContributorName());
        assertTrue(l.getContributorMemberId().isEmpty());
    }
}
