package com.chf.bbcms.sync.application.port.out;

import com.chf.bbcms.sync.domain.SyncChange;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import reactor.core.publisher.Flux;

import java.time.Instant;

/**
 * Lecture générique des changements d'une entité depuis un instant donné.
 * Les implémentations adapter/out interrogent la table correspondante via DatabaseClient.
 */
public interface SyncReadPort {
    Flux<SyncChange> findChangesSince(SyncEntityKind kind, Instant since, int limit);
}
