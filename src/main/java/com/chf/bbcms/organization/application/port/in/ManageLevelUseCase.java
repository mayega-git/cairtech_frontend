package com.chf.bbcms.organization.application.port.in;

import com.chf.bbcms.organization.domain.Level;
import com.chf.bbcms.organization.domain.LevelType;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ManageLevelUseCase {

    Mono<Level> create(UUID bibleClubId, String name, String profile, LevelType type);
    Mono<Level> rename(UUID levelId, String newName);
    Mono<Level> assignPresident(UUID levelId, UUID memberId);
    Mono<Level> assignVicePresident(UUID levelId, UUID memberId);
    Flux<Level> listByBibleClub(UUID bibleClubId);
    Mono<Void> deleteById(UUID levelId);
}
