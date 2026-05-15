package com.chf.bbcms.meeting.domain;

import java.time.Instant;
import java.util.UUID;

public record MeetingPicture(UUID id, UUID meetingId, UUID fileId, String caption, Instant takenAt) {

    public static MeetingPicture create(UUID meetingId, UUID fileId, String caption) {
        if (meetingId == null) throw new IllegalArgumentException("meetingId required");
        if (fileId == null) throw new IllegalArgumentException("fileId required");
        return new MeetingPicture(null, meetingId, fileId, caption, Instant.now());
    }
}
