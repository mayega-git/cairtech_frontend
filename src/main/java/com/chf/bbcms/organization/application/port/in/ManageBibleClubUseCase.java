package com.chf.bbcms.organization.application.port.in;

import com.chf.bbcms.organization.domain.BibleClub;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

public interface ManageBibleClubUseCase {

    Mono<BibleClub> create(CreateBibleClubCommand cmd);
    Mono<BibleClub> update(UUID id, UpdateBibleClubCommand cmd);
    Mono<BibleClub> setGoal(UUID id, int goalNbFaithful);
    Mono<BibleClub> assignTriumvirate(UUID id, UUID presidentId, UUID vicePresidentId, UUID secretaryId);
    Mono<BibleClub> findById(UUID id);
    Flux<BibleClub> listAll();
    Mono<Void> deleteById(UUID id);

    record CreateBibleClubCommand(String name, String profile, String schoolName,
                                  Integer goalNbFaithful, LocalDate dateCreated) {}

    record UpdateBibleClubCommand(String name, String profile, String schoolName) {}
}
