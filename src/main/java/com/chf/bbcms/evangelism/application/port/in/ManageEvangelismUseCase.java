package com.chf.bbcms.evangelism.application.port.in;

import com.chf.bbcms.evangelism.domain.EvangelismProgram;
import com.chf.bbcms.evangelism.domain.EvangelismProgramType;
import com.chf.bbcms.evangelism.domain.EvangelismRecord;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

public interface ManageEvangelismUseCase {

    Mono<EvangelismProgram> draftProgram(String title, EvangelismProgramType type, int objective);
    Mono<EvangelismProgram> addProgramDate(UUID programId, LocalDate date);
    Mono<EvangelismProgram> addProgramBibleClub(UUID programId, UUID bibleClubId);
    Mono<EvangelismProgram> activateProgram(UUID programId);
    Mono<EvangelismProgram> closeProgram(UUID programId);
    Mono<EvangelismProgram> findProgramById(UUID programId);
    Flux<EvangelismProgram> listPrograms();

    Mono<EvangelismRecord> recordSession(RecordSessionCommand cmd);
    Flux<EvangelismRecord> listRecordsByProgram(UUID programId);

    record RecordSessionCommand(
            UUID programId, LocalDate date,
            int preached, int believed, int encouraged, int tracts,
            String savedContacts, String notes,
            Set<UUID> participantMemberIds
    ) {}
}
