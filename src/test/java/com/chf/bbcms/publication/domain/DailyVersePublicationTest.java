package com.chf.bbcms.publication.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class DailyVersePublicationTest {

    @Test
    void draft_initializes_DRAFT_with_default_audience() {
        DailyVersePublication p = DailyVersePublication.draft("Verset du jour", "Jn 3:16",
                "Car Dieu a tant aimé...", null, null, LocalDate.now(), null);
        assertEquals(PublicationStatus.DRAFT, p.getStatus());
        assertEquals(PublicationAudience.CHF, p.getAudience());
    }

    @Test
    void schedule_only_from_DRAFT() {
        DailyVersePublication p = DailyVersePublication.draft("X", "Jn 3:16", "...",
                null, null, LocalDate.now(), null);
        p.schedule();
        assertEquals(PublicationStatus.SCHEDULED, p.getStatus());
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, p::schedule);
        assertEquals("BBCMS_PUB_BAD_STATE", ex.getCode());
    }

    @Test
    void publishNow_terminal() {
        DailyVersePublication p = DailyVersePublication.draft("X", "Jn 3:16", "...",
                null, null, LocalDate.now(), null);
        p.publishNow();
        assertEquals(PublicationStatus.PUBLISHED, p.getStatus());
        assertThrows(BusinessRuleViolation.class, p::publishNow);
    }

    @Test
    void rejects_blank_required_fields() {
        assertThrows(IllegalArgumentException.class,
                () -> DailyVersePublication.draft("", "Jn 3:16", "x", null, null, LocalDate.now(), null));
        assertThrows(IllegalArgumentException.class,
                () -> DailyVersePublication.draft("T", " ", "x", null, null, LocalDate.now(), null));
        assertThrows(IllegalArgumentException.class,
                () -> DailyVersePublication.draft("T", "Jn 3:16", "", null, null, LocalDate.now(), null));
    }
}
