package com.chf.bbcms.event.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;

import static org.junit.jupiter.api.Assertions.*;

class EventTest {

    private Event plan() {
        return Event.plan("Congress 2025", EventType.NATIONAL_CONGRESS,
                Instant.now().plus(Duration.ofDays(30)),
                Instant.now().plus(Duration.ofDays(33)),
                "Yaoundé", 100, null);
    }

    @Test
    void plan_initializes_PLANNED() {
        Event e = plan();
        assertEquals(EventStatus.PLANNED, e.getStatus());
        assertTrue(e.acceptsEnrollment());
    }

    @Test
    void openRegistration_only_from_PLANNED() {
        Event e = plan();
        e.openRegistration();
        assertEquals(EventStatus.REGISTRATION_OPEN, e.getStatus());
        assertThrows(BusinessRuleViolation.class, e::openRegistration);
    }

    @Test
    void start_then_end_computes_duration() {
        Event e = plan();
        Instant start = Instant.now();
        Instant end = start.plusSeconds(7200);
        e.start(start);
        e.end(end);
        assertEquals(EventStatus.ENDED, e.getStatus());
        assertEquals(120, e.getDurationMinutes());
    }

    @Test
    void cannot_cancel_after_ENDED() {
        Event e = plan();
        e.start(Instant.now());
        e.end(Instant.now());
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, e::cancel);
        assertEquals("BBCMS_EVENT_TERMINAL", ex.getCode());
    }

    @Test
    void enrollment_rejected_when_ongoing() {
        Event e = plan();
        e.start(Instant.now());
        assertFalse(e.acceptsEnrollment());
    }
}
