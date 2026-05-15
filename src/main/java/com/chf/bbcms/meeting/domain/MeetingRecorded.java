package com.chf.bbcms.meeting.domain;

import com.chf.bbcms.shared.domain.DomainEvent;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Émis lors du passage d'une réunion en RECORDED. Consommé par l'attendance/listener
 * pour incrémenter les scores des membres présents.
 */
public record MeetingRecorded(
        UUID meetingId,
        MeetingType meetingType,
        UUID bibleClubId,
        UUID levelId,
        LocalDate dateOccurred,
        List<UUID> presentMemberIds,
        int nbBelievers,
        Instant occurredAt
) implements DomainEvent {

    public static MeetingRecorded of(Meeting m, List<UUID> presentMemberIds) {
        return new MeetingRecorded(
                m.getId(),
                m.getType(),
                m.getBibleClubId().orElse(null),
                m.getLevelId().orElse(null),
                m.getDateOccurred(),
                presentMemberIds,
                m.getNbBelievers(),
                Instant.now()
        );
    }

    @Override public String type() { return "MEETING_RECORDED"; }
    @Override public UUID aggregateId() { return meetingId; }
}
