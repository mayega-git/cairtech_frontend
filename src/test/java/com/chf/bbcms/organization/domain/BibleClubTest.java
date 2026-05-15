package com.chf.bbcms.organization.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class BibleClubTest {

    @Test
    void create_initializes_active_status_with_today() {
        BibleClub b = BibleClub.create("BBC Yaoundé I", null, "Université Yaoundé I", 50, null);
        assertEquals(BibleClubStatus.ACTIVE, b.getStatus());
        assertNotNull(b.getDateCreated());
        assertEquals(50, b.getGoalNbFaithful());
    }

    @Test
    void rename_rejects_blank() {
        BibleClub b = BibleClub.create("X", null, null, null, null);
        assertThrows(IllegalArgumentException.class, () -> b.rename(""));
    }

    @Test
    void startReset_only_when_active() {
        BibleClub b = BibleClub.create("X", null, null, null, null);
        b.startReset();
        assertEquals(BibleClubStatus.UNDER_RESET, b.getStatus());
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, b::startReset);
        assertEquals("BBCMS_BBC_NOT_ACTIVE", ex.getCode());
    }

    @Test
    void writes_frozen_under_reset() {
        BibleClub b = BibleClub.create("X", null, null, null, null);
        b.startReset();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, () -> b.setGoalNbFaithful(100));
        assertEquals("BBCMS_BBC_FROZEN", ex.getCode());
    }

    @Test
    void finishReset_returns_to_active() {
        BibleClub b = BibleClub.create("X", null, null, null, null);
        b.startReset();
        b.finishReset();
        assertEquals(BibleClubStatus.ACTIVE, b.getStatus());
    }

    @Test
    void assign_triumvirate_works_when_active() {
        BibleClub b = BibleClub.create("X", null, null, null, null);
        UUID p = UUID.randomUUID();
        b.assignPresident(p);
        assertEquals(p, b.getPresidentMemberId());
    }
}
