package com.chf.bbcms.intercession.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PrayerSlotTest {

    @Test
    void create_rejects_end_before_start() {
        Instant now = Instant.now();
        assertThrows(IllegalArgumentException.class,
                () -> PrayerSlot.create(UUID.randomUUID(), now, now.minusSeconds(1)));
    }

    @Test
    void cover_assigns_intercessor() {
        PrayerSlot s = PrayerSlot.create(UUID.randomUUID(), Instant.now(),
                Instant.now().plusSeconds(3600));
        UUID intercessor = UUID.randomUUID();
        s.cover(intercessor, "Disponible");
        assertTrue(s.isCovered());
        assertEquals(intercessor, s.getIntercessorMemberId().orElseThrow());
    }

    @Test
    void cover_twice_rejected() {
        PrayerSlot s = PrayerSlot.create(UUID.randomUUID(), Instant.now(),
                Instant.now().plusSeconds(3600));
        s.cover(UUID.randomUUID(), null);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> s.cover(UUID.randomUUID(), null));
        assertEquals("BBCMS_SLOT_ALREADY_COVERED", ex.getCode());
    }

    @Test
    void uncover_clears_intercessor() {
        PrayerSlot s = PrayerSlot.create(UUID.randomUUID(), Instant.now(),
                Instant.now().plusSeconds(3600));
        s.cover(UUID.randomUUID(), null);
        s.uncover();
        assertFalse(s.isCovered());
        assertTrue(s.getIntercessorMemberId().isEmpty());
    }
}
