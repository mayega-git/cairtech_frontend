package com.chf.bbcms.discipleship.application.port.in;

import com.chf.bbcms.discipleship.domain.DiscipleLink;
import com.chf.bbcms.discipleship.domain.DiscipleshipRecord;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Set;
import java.util.UUID;

public interface ManageDiscipleshipUseCase {

    Mono<DiscipleLink> assignDisciple(UUID makerId, UUID discipleId);
    Mono<DiscipleLink> endDiscipleLink(UUID linkId, LocalDate when);
    Flux<DiscipleLink> listActiveByMaker(UUID makerId);

    Mono<DiscipleshipRecord> recordSession(RecordSessionCommand cmd);
    Flux<DiscipleshipRecord> listByMaker(UUID makerId);

    record RecordSessionCommand(
            UUID makerId, UUID meetingId, LocalDate dateOccurred,
            LocalTime startTime, LocalTime endTime, String theme, String location,
            String description, String disciplesState, String investment,
            Set<UUID> presentDiscipleIds
    ) {}
}
