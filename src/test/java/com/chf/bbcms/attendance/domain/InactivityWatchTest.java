package com.chf.bbcms.attendance.domain;

import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class InactivityWatchTest {

    @Test
    void recordPresence_resets_consecutive_absences() {
        InactivityWatch w = InactivityWatch.initial(UUID.randomUUID(), 90);
        w.incrementAbsence();
        w.incrementAbsence();
        w.recordPresence(Instant.now());
        assertEquals(0, w.getConsecutiveAbsences());
    }

    @Test
    void shouldBeRemoved_true_when_lastSeen_older_than_threshold() {
        InactivityWatch w = InactivityWatch.initial(UUID.randomUUID(), 90);
        Instant lastSeen = Instant.now().minus(Duration.ofDays(91));
        w.recordPresence(lastSeen);
        assertTrue(w.shouldBeRemoved(Instant.now()));
    }

    @Test
    void shouldBeRemoved_false_when_within_threshold() {
        InactivityWatch w = InactivityWatch.initial(UUID.randomUUID(), 90);
        w.recordPresence(Instant.now().minus(Duration.ofDays(30)));
        assertFalse(w.shouldBeRemoved(Instant.now()));
    }

    @Test
    void shouldBeMarkedInactive_true_after_warning_days() {
        InactivityWatch w = InactivityWatch.initial(UUID.randomUUID(), 90);
        w.recordPresence(Instant.now().minus(Duration.ofDays(31)));
        assertTrue(w.shouldBeMarkedInactive(Instant.now(), 30));
        assertFalse(w.shouldBeMarkedInactive(Instant.now(), 60));
    }

    @Test
    void markRemoved_sets_removedAt_and_blocks_further_removals() {
        InactivityWatch w = InactivityWatch.initial(UUID.randomUUID(), 90);
        w.recordPresence(Instant.now().minus(Duration.ofDays(91)));
        w.markRemoved(Instant.now());
        assertNotNull(w.getRemovedAt());
        assertFalse(w.shouldBeRemoved(Instant.now()));
    }
}
