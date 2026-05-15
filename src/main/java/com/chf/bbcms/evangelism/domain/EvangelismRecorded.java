package com.chf.bbcms.evangelism.domain;

import com.chf.bbcms.shared.domain.DomainEvent;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Émis quand un EvangelismRecord est créé. Consommé par attendance pour incrémenter
 * le score de chaque participant (les events/évangélisation comptent — décision validée).
 */
public record EvangelismRecorded(
        UUID evangelismRecordId,
        UUID programId,
        List<UUID> participantMemberIds,
        Instant occurredAt
) implements DomainEvent {
    @Override public String type() { return "EVANGELISM_RECORDED"; }
    @Override public UUID aggregateId() { return evangelismRecordId; }
}
