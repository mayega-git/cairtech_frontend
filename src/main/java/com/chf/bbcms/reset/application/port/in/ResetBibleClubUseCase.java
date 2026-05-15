package com.chf.bbcms.reset.application.port.in;

import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ResetBibleClubUseCase {

    Mono<BibleClubResetSnapshot> reset(UUID bibleClubId, int academicYear, UUID actorId);
}
