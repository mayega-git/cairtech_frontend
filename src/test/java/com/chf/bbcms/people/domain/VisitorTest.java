package com.chf.bbcms.people.domain;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class VisitorTest {

    @Test
    void forMeeting_requires_meetingId() {
        assertThrows(IllegalArgumentException.class,
                () -> Visitor.forMeeting("Jean", null, null, null, LocalDate.now()));
    }

    @Test
    void forEvent_requires_eventId() {
        assertThrows(IllegalArgumentException.class,
                () -> Visitor.forEvent("Jean", null, null, null, LocalDate.now()));
    }

    @Test
    void forMeeting_attaches_only_to_meeting() {
        UUID meetingId = UUID.randomUUID();
        Visitor v = Visitor.forMeeting("Jean", "Dupont", "+237", meetingId, LocalDate.of(2025, 1, 15));
        assertEquals(meetingId, v.getMeetingId().orElseThrow());
        assertTrue(v.getEventId().isEmpty());
    }

    @Test
    void blank_firstNames_rejected() {
        assertThrows(IllegalArgumentException.class,
                () -> Visitor.forMeeting("", null, null, UUID.randomUUID(), null));
    }
}
