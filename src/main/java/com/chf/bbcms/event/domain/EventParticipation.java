package com.chf.bbcms.event.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public class EventParticipation {

    private UUID id;
    private UUID eventId;
    private UUID memberId;
    private UUID visitorId;
    private Instant registeredAt;
    private boolean present;
    private Instant presentAt;

    protected EventParticipation() {}

    public static EventParticipation enrollMember(UUID eventId, UUID memberId) {
        if (memberId == null) throw new IllegalArgumentException("memberId required");
        return create(eventId, memberId, null);
    }

    public static EventParticipation enrollVisitor(UUID eventId, UUID visitorId) {
        if (visitorId == null) throw new IllegalArgumentException("visitorId required");
        return create(eventId, null, visitorId);
    }

    public static EventParticipation rehydrate(UUID id, UUID eventId, UUID memberId, UUID visitorId,
                                               Instant registeredAt, boolean present, Instant presentAt) {
        EventParticipation p = new EventParticipation();
        p.id = id;
        p.eventId = eventId;
        p.memberId = memberId;
        p.visitorId = visitorId;
        p.registeredAt = registeredAt;
        p.present = present;
        p.presentAt = presentAt;
        return p;
    }

    private static EventParticipation create(UUID eventId, UUID memberId, UUID visitorId) {
        if (eventId == null) throw new IllegalArgumentException("eventId required");
        if (memberId != null && visitorId != null)
            throw new BusinessRuleViolation("BBCMS_PARTICIPATION_BOTH_LINKS",
                    "EventParticipation cannot have both memberId and visitorId");
        EventParticipation p = new EventParticipation();
        p.eventId = eventId;
        p.memberId = memberId;
        p.visitorId = visitorId;
        p.registeredAt = Instant.now();
        p.present = false;
        return p;
    }

    public void markPresent(Instant when) {
        this.present = true;
        this.presentAt = when == null ? Instant.now() : when;
    }

    public UUID getId() { return id; }
    public UUID getEventId() { return eventId; }
    public Optional<UUID> getMemberId() { return Optional.ofNullable(memberId); }
    public Optional<UUID> getVisitorId() { return Optional.ofNullable(visitorId); }
    public Instant getRegisteredAt() { return registeredAt; }
    public boolean isPresent() { return present; }
    public Instant getPresentAt() { return presentAt; }
}
