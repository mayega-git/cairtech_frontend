package com.chf.bbcms.sync.application.port.out;

import com.chf.bbcms.sync.domain.SyncCursor;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface SyncCursorRepository {
    Mono<SyncCursor> find(UUID userAccountId, String deviceId, SyncEntityKind kind);
    Mono<SyncCursor> save(SyncCursor cursor);
}
