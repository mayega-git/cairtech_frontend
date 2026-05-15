package com.chf.bbcms.finance.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class FinancialContributionTest {

    @Test
    void open_initializes_with_XAF_default() {
        FinancialContribution c = FinancialContribution.open(UUID.randomUUID(), "Camp",
                null, BigDecimal.valueOf(100000), null);
        assertEquals("XAF", c.getCurrency());
        assertEquals(ContributionStatus.OPEN, c.getStatus());
        assertEquals(0, c.getTotalContributed().compareTo(BigDecimal.ZERO));
    }

    @Test
    void addAmount_increments_total() {
        FinancialContribution c = FinancialContribution.open(UUID.randomUUID(), "X",
                null, BigDecimal.valueOf(100000), null);
        c.addAmount(BigDecimal.valueOf(25000));
        c.addAmount(BigDecimal.valueOf(15000));
        assertEquals(0, c.getTotalContributed().compareTo(BigDecimal.valueOf(40000)));
    }

    @Test
    void addAmount_rejects_when_closed() {
        FinancialContribution c = FinancialContribution.open(UUID.randomUUID(), "X",
                null, BigDecimal.valueOf(100), null);
        c.close(null);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> c.addAmount(BigDecimal.TEN));
        assertEquals("BBCMS_CONTRIB_NOT_OPEN", ex.getCode());
    }

    @Test
    void addAmount_rejects_zero_or_negative() {
        FinancialContribution c = FinancialContribution.open(UUID.randomUUID(), "X",
                null, BigDecimal.valueOf(100), null);
        assertThrows(IllegalArgumentException.class, () -> c.addAmount(BigDecimal.ZERO));
        assertThrows(IllegalArgumentException.class, () -> c.addAmount(BigDecimal.valueOf(-1)));
    }

    @Test
    void objective_reached_and_percentage() {
        FinancialContribution c = FinancialContribution.open(UUID.randomUUID(), "X",
                null, BigDecimal.valueOf(1000), null);
        c.addAmount(BigDecimal.valueOf(500));
        assertFalse(c.objectiveReached());
        assertEquals(50.0, c.percentageReached());
        c.addAmount(BigDecimal.valueOf(500));
        assertTrue(c.objectiveReached());
    }
}
