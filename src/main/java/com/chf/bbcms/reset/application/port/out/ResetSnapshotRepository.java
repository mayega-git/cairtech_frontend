package com.chf.bbcms.reset.application.port.out;

import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ResetSnapshotRepository {
    Mono<BibleClubResetSnapshot> save(BibleClubResetSnapshot snapshot);
    Mono<BibleClubResetSnapshot> findByBibleClubAndYear(UUID bibleClubId, int academicYear);
    Flux<BibleClubResetSnapshot> findByBibleClub(UUID bibleClubId);
}
