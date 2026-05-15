package com.chf.bbcms.attendance.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class AttendanceScoreTest {

    private static final BigDecimal THRESHOLD_50 = BigDecimal.valueOf(50);

    @Test
    void initial_zero_state() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        assertEquals(0, s.getScore());
        assertEquals(0, s.getTotalEligible());
        assertFalse(s.isFaithful());
    }

    @Test
    void recompute_zero_eligible_keeps_unfaithful() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        s.incrementBy(5);
        s.recompute(0, THRESHOLD_50);
        assertFalse(s.isFaithful());
        assertEquals(0, s.getFaithfulPercentage().compareTo(BigDecimal.ZERO));
    }

    @Test
    void recompute_above_threshold_marks_faithful() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        s.incrementBy(6);
        s.recompute(10, THRESHOLD_50);
        assertTrue(s.isFaithful());
        assertEquals(0, s.getFaithfulPercentage().compareTo(BigDecimal.valueOf(60.0).setScale(2)));
    }

    @Test
    void recompute_below_threshold_marks_unfaithful() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        s.incrementBy(3);
        s.recompute(10, THRESHOLD_50);
        assertFalse(s.isFaithful());
        assertEquals(0, s.getFaithfulPercentage().compareTo(BigDecimal.valueOf(30.0).setScale(2)));
    }

    @Test
    void recompute_exactly_at_threshold_is_faithful() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        s.incrementBy(5);
        s.recompute(10, THRESHOLD_50);
        assertTrue(s.isFaithful());
    }

    @Test
    void resetForNewYear_zeroes_everything() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        s.incrementBy(8);
        s.recompute(10, THRESHOLD_50);
        s.resetForNewYear();
        assertEquals(0, s.getScore());
        assertEquals(0, s.getTotalEligible());
        assertFalse(s.isFaithful());
    }

    @Test
    void incrementBy_negative_rejected() {
        AttendanceScore s = AttendanceScore.initial(UUID.randomUUID(), null, null, 2025);
        assertThrows(IllegalArgumentException.class, () -> s.incrementBy(-1));
    }
}
