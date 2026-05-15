package com.chf.bbcms.people.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

/**
 * Visiteur ponctuel d'une réunion ou d'un événement. Ne possède pas de UserAccount.
 * Anti-pattern FK polymorphe corrigé: deux colonnes nullables exclusives (meeting_id XOR event_id).
 */
public class Visitor extends BaseEntity {

    private String firstNames;
    private String nextNames;
    private String phoneNumber;
    private UUID meetingId;
    private UUID eventId;
    private LocalDate visitDate;

    protected Visitor() {}

    public static Visitor forMeeting(String firstNames, String nextNames, String phoneNumber,
                                     UUID meetingId, LocalDate visitDate) {
        if (meetingId == null) throw new IllegalArgumentException("meetingId required");
        return create(firstNames, nextNames, phoneNumber, meetingId, null, visitDate);
    }

    public static Visitor forEvent(String firstNames, String nextNames, String phoneNumber,
                                   UUID eventId, LocalDate visitDate) {
        if (eventId == null) throw new IllegalArgumentException("eventId required");
        return create(firstNames, nextNames, phoneNumber, null, eventId, visitDate);
    }

    public static Visitor rehydrate(UUID id, String firstNames, String nextNames, String phoneNumber,
                                    UUID meetingId, UUID eventId, LocalDate visitDate,
                                    Instant createdAt, Instant updatedAt, Long version) {
        Visitor v = new Visitor();
        v.id = id;
        v.firstNames = firstNames;
        v.nextNames = nextNames;
        v.phoneNumber = phoneNumber;
        v.meetingId = meetingId;
        v.eventId = eventId;
        v.visitDate = visitDate;
        v.createdAt = createdAt;
        v.updatedAt = updatedAt;
        v.version = version;
        return v;
    }

    private static Visitor create(String firstNames, String nextNames, String phoneNumber,
                                  UUID meetingId, UUID eventId, LocalDate visitDate) {
        if (firstNames == null || firstNames.isBlank())
            throw new IllegalArgumentException("firstNames is required");
        if (meetingId != null && eventId != null)
            throw new BusinessRuleViolation("BBCMS_VISITOR_BOTH_LINKS",
                    "A Visitor must be attached to either a meeting or an event, not both");
        Visitor v = new Visitor();
        v.firstNames = firstNames;
        v.nextNames = nextNames;
        v.phoneNumber = phoneNumber;
        v.meetingId = meetingId;
        v.eventId = eventId;
        v.visitDate = visitDate == null ? LocalDate.now() : visitDate;
        return v;
    }

    public String getFirstNames() { return firstNames; }
    public String getNextNames() { return nextNames; }
    public String getPhoneNumber() { return phoneNumber; }
    public Optional<UUID> getMeetingId() { return Optional.ofNullable(meetingId); }
    public Optional<UUID> getEventId() { return Optional.ofNullable(eventId); }
    public LocalDate getVisitDate() { return visitDate; }
}
