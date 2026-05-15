package com.chf.bbcms.discipleship.application.port.out;

import com.chf.bbcms.discipleship.domain.DiscipleLink;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface DiscipleLinkRepository {
    Mono<DiscipleLink> findById(UUID id);
    Flux<DiscipleLink> findActiveByMaker(UUID makerId);
    Flux<DiscipleLink> findActiveByDisciple(UUID discipleId);
    Mono<DiscipleLink> save(DiscipleLink link);
}
