package com.chf.bbcms.meeting.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class MeetingTest {

    private Meeting plan() {
        return Meeting.plan("Class meeting", MeetingType.CLASS_MEETING,
                UUID.randomUUID(), UUID.randomUUID(),
                LocalDate.of(2025, 10, 5), LocalTime.of(15, 0), LocalTime.of(17, 0), 20);
    }

    @Test
    void plan_initializes_status_PLANNED() {
        Meeting m = plan();
        assertEquals(MeetingStatus.PLANNED, m.getStatus());
        assertEquals(20, m.getMaxPictures());
    }

    @Test
    void plan_rejects_blank_title() {
        assertThrows(IllegalArgumentException.class,
                () -> Meeting.plan("", MeetingType.CLASS_MEETING, UUID.randomUUID(), UUID.randomUUID(),
                        LocalDate.now(), LocalTime.now(), null, 20));
    }

    @Test
    void start_then_end_then_record_full_lifecycle() {
        Meeting m = plan();
        m.start(LocalDate.of(2025, 10, 5), LocalTime.of(15, 5));
        assertEquals(MeetingStatus.ONGOING, m.getStatus());
        m.end(LocalTime.of(17, 5));
        assertEquals(MeetingStatus.ENDED, m.getStatus());
        assertEquals(120, m.getDurationMinutes());
        m.record(null, null, LocalTime.of(17, 5), 3, "OK", 0);
        assertEquals(MeetingStatus.RECORDED, m.getStatus());
        assertEquals(3, m.getNbBelievers());
    }

    @Test
    void record_directly_from_PLANNED_works() {
        Meeting m = plan();
        m.record(LocalDate.of(2025, 10, 5), LocalTime.of(15, 0), LocalTime.of(17, 0), 5, "summary", 2);
        assertEquals(MeetingStatus.RECORDED, m.getStatus());
    }

    @Test
    void record_rejects_when_pictures_exceed_max() {
        Meeting m = plan();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> m.record(LocalDate.now(), null, null, 0, null, 21));
        assertEquals("BBCMS_MEETING_MAX_PICTURES", ex.getCode());
    }

    @Test
    void cannot_record_a_RECORDED_meeting() {
        Meeting m = plan();
        m.record(LocalDate.now(), null, null, 0, null, 0);
        assertThrows(BusinessRuleViolation.class,
                () -> m.record(LocalDate.now(), null, null, 0, null, 0));
    }

    @Test
    void cannot_cancel_a_RECORDED_meeting() {
        Meeting m = plan();
        m.record(LocalDate.now(), null, null, 0, null, 0);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, m::cancel);
        assertEquals("BBCMS_MEETING_TERMINAL", ex.getCode());
    }

    @Test
    void cancel_from_PLANNED_works() {
        Meeting m = plan();
        m.cancel();
        assertEquals(MeetingStatus.CANCELLED, m.getStatus());
    }

    @Test
    void academic_meeting_does_not_count_for_faithfulness() {
        assertFalse(MeetingType.ACADEMIC_MEETING.countsForFaithfulness());
        assertTrue(MeetingType.CLASS_MEETING.countsForFaithfulness());
    }
}
