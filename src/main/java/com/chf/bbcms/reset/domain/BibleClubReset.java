package com.chf.bbcms.reset.domain;

import com.chf.bbcms.shared.domain.DomainEvent;

import java.time.Instant;
import java.util.UUID;

/** Émis à la fin réussie d'un reset annuel. */
public record BibleClubReset(
        UUID bibleClubId,
        int academicYear,
        int nbMembersBefore,
        int nbFaithfulBefore,
        UUID archiveFileId,
        UUID snapshotId,
        Instant occurredAt
) implements DomainEvent {
    @Override public String type() { return "BBC_RESET"; }
    @Override public UUID aggregateId() { return bibleClubId; }
}
