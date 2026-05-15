package com.chf.bbcms.attendance.domain;

import java.time.Instant;
import java.util.UUID;

/**
 * Trace immuable d'une présence comptée dans le score de fidélité.
 * Idempotence garantie par UNIQUE (member_id, source, meeting_id, event_id, evangelism_record_id).
 */
public record FaithfulnessRecord(
        UUID id,
        UUID attendanceScoreId,
        UUID memberId,
        UUID meetingId,
        UUID eventId,
        UUID evangelismRecordId,
        FaithfulnessSource source,
        Instant countedAt,
        int weight
) {
    public static FaithfulnessRecord forMeeting(UUID scoreId, UUID memberId, UUID meetingId, int weight) {
        return new FaithfulnessRecord(null, scoreId, memberId, meetingId, null, null,
                FaithfulnessSource.MEETING, Instant.now(), weight);
    }

    public static FaithfulnessRecord forEvent(UUID scoreId, UUID memberId, UUID eventId, int weight) {
        return new FaithfulnessRecord(null, scoreId, memberId, null, eventId, null,
                FaithfulnessSource.EVENT, Instant.now(), weight);
    }

    public static FaithfulnessRecord forEvangelism(UUID scoreId, UUID memberId, UUID recordId, int weight) {
        return new FaithfulnessRecord(null, scoreId, memberId, null, null, recordId,
                FaithfulnessSource.EVANGELISM, Instant.now(), weight);
    }
}
