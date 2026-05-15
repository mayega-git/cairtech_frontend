package com.chf.bbcms.shared.domain;

import java.time.Instant;
import java.util.UUID;

/**
 * Marqueur pour tous les événements de domaine.
 * Persistés dans bbcms_domain_event (transactional outbox)
 * puis republiés par OutboxPublisher → Spring ApplicationEventPublisher.
 */
public interface DomainEvent {
    String type();
    UUID aggregateId();
    Instant occurredAt();
}
