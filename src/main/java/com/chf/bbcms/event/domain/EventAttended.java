package com.chf.bbcms.event.domain;

import com.chf.bbcms.shared.domain.DomainEvent;

import java.time.Instant;
import java.util.UUID;

/**
 * Émis lorsqu'une présence à un événement est enregistrée. Consommé par attendance
 * pour incrémenter le score (les events comptent dans la fidélité, décision validée).
 */
public record EventAttended(UUID eventId, UUID memberId, Instant occurredAt) implements DomainEvent {
    @Override public String type() { return "EVENT_ATTENDED"; }
    @Override public UUID aggregateId() { return eventId; }
}
