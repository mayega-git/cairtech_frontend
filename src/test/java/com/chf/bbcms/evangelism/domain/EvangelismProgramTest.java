package com.chf.bbcms.evangelism.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class EvangelismProgramTest {

    @Test
    void draft_initializes_DRAFT() {
        EvangelismProgram p = EvangelismProgram.draft("Campagne 2025",
                EvangelismProgramType.INTERNAL_BBC, 50);
        assertEquals(EvangelismProgramStatus.DRAFT, p.getStatus());
        assertEquals(50, p.getObjectiveBelievers());
    }

    @Test
    void activate_requires_at_least_one_date() {
        EvangelismProgram p = EvangelismProgram.draft("X", EvangelismProgramType.JOINT, 100);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, p::activate);
        assertEquals("BBCMS_EVG_NO_DATES", ex.getCode());
    }

    @Test
    void validateRecordDate_rejects_date_outside_program() {
        EvangelismProgram p = EvangelismProgram.draft("X", EvangelismProgramType.JOINT, 100);
        p.addDate(LocalDate.of(2025, 10, 1));
        p.addDate(LocalDate.of(2025, 10, 2));
        p.activate();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> p.validateRecordDate(LocalDate.of(2025, 10, 3)));
        assertEquals("BBCMS_EVG_RECORD_DATE_OUT_OF_PROGRAM", ex.getCode());
    }

    @Test
    void aggregate_only_when_active() {
        EvangelismProgram p = EvangelismProgram.draft("X", EvangelismProgramType.JOINT, 100);
        p.addDate(LocalDate.now());
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> p.aggregate(10, 5, 2));
        assertEquals("BBCMS_EVG_NOT_ACTIVE", ex.getCode());
        p.activate();
        p.aggregate(10, 5, 2);
        assertEquals(10, p.getTotalPreached());
        assertEquals(5, p.getTotalSaved());
    }

    @Test
    void percentage_reached_zero_objective() {
        EvangelismProgram p = EvangelismProgram.draft("X", EvangelismProgramType.JOINT, 0);
        assertEquals(0d, p.percentageReached());
    }

    @Test
    void cannot_mutate_after_close() {
        EvangelismProgram p = EvangelismProgram.draft("X", EvangelismProgramType.JOINT, 100);
        p.addDate(LocalDate.now());
        p.activate();
        p.close();
        assertThrows(BusinessRuleViolation.class, () -> p.addDate(LocalDate.now()));
    }
}
