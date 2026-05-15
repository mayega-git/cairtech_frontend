package com.chf.bbcms.organization.application.port.out;

import com.chf.bbcms.organization.domain.Level;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface LevelRepository {
    Mono<Level> findById(UUID id);
    Flux<Level> findByBibleClubId(UUID bibleClubId);
    Mono<Level> save(Level level);
    Mono<Void> deleteById(UUID id);
}
