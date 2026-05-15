package com.chf.bbcms.sync.application.service;

import com.chf.bbcms.sync.application.port.in.SyncUseCase;
import com.chf.bbcms.sync.application.port.out.SyncCursorRepository;
import com.chf.bbcms.sync.application.port.out.SyncReadPort;
import com.chf.bbcms.sync.domain.SyncChange;
import com.chf.bbcms.sync.domain.SyncCursor;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class SyncService implements SyncUseCase {

    private static final int MAX_LIMIT = 500;

    private final SyncCursorRepository cursorRepository;
    private final SyncReadPort syncReadPort;

    public SyncService(SyncCursorRepository cursorRepository, SyncReadPort syncReadPort) {
        this.cursorRepository = cursorRepository;
        this.syncReadPort = syncReadPort;
    }

    @Override
    public Mono<SyncBatch> pullChanges(UUID userAccountId, String deviceId,
                                       SyncEntityKind kind, Instant overrideSince, int limit) {
        int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
        return cursorRepository.find(userAccountId, deviceId, kind)
                .switchIfEmpty(Mono.fromCallable(() -> SyncCursor.initial(userAccountId, deviceId, kind)))
                .flatMap(cursor -> {
                    Instant since = overrideSince != null ? overrideSince : cursor.lastSyncedAt();
                    return syncReadPort.findChangesSince(kind, since, safeLimit)
                            .collectList()
                            .flatMap(changes -> {
                                Instant advanced = changes.isEmpty()
                                        ? since
                                        : changes.get(changes.size() - 1).updatedAt();
                                SyncCursor next = cursor.advance(advanced);
                                return cursorRepository.save(next)
                                        .thenReturn(buildBatch(kind, since, advanced, changes));
                            });
                });
    }

    private SyncBatch buildBatch(SyncEntityKind kind, Instant since, Instant advanced,
                                 List<SyncChange> changes) {
        return new SyncBatch(kind, since, advanced, changes.size(), changes);
    }
}
