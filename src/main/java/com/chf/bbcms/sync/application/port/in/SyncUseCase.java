package com.chf.bbcms.sync.application.port.in;

import com.chf.bbcms.sync.domain.SyncChange;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface SyncUseCase {

    /**
     * Récupère les changements d'une entité depuis le dernier curseur du device,
     * ou depuis l'instant fourni si pas de curseur. Met à jour le curseur après lecture.
     */
    Mono<SyncBatch> pullChanges(UUID userAccountId, String deviceId,
                                SyncEntityKind kind, Instant overrideSince, int limit);

    record SyncBatch(
            SyncEntityKind kind,
            Instant since,
            Instant cursorAdvancedTo,
            int count,
            List<SyncChange> changes
    ) {}
}
