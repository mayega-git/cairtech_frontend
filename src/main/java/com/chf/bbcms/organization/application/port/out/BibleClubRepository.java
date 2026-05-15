package com.chf.bbcms.organization.application.port.out;

import com.chf.bbcms.organization.domain.BibleClub;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface BibleClubRepository {
    Mono<BibleClub> findById(UUID id);
    Flux<BibleClub> findAll();
    Mono<BibleClub> save(BibleClub bibleClub);
    Mono<Void> deleteById(UUID id);
}
