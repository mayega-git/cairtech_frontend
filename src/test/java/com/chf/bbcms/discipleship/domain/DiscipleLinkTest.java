package com.chf.bbcms.discipleship.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class DiscipleLinkTest {

    @Test
    void cannot_be_self_disciple() {
        UUID self = UUID.randomUUID();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> DiscipleLink.assign(self, self));
        assertEquals("BBCMS_DISCIPLE_SELF", ex.getCode());
    }

    @Test
    void assign_creates_active_link() {
        DiscipleLink l = DiscipleLink.assign(UUID.randomUUID(), UUID.randomUUID());
        assertTrue(l.isActive());
        assertNull(l.getDateEnded());
    }

    @Test
    void end_marks_inactive() {
        DiscipleLink l = DiscipleLink.assign(UUID.randomUUID(), UUID.randomUUID());
        l.end(LocalDate.now());
        assertFalse(l.isActive());
        assertNotNull(l.getDateEnded());
    }
}
