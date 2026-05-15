package com.chf.bbcms.evangelism.application.service;

import com.chf.bbcms.evangelism.application.port.in.ManageEvangelismUseCase;
import com.chf.bbcms.evangelism.application.port.out.EvangelismProgramRepository;
import com.chf.bbcms.evangelism.application.port.out.EvangelismRecordRepository;
import com.chf.bbcms.evangelism.domain.EvangelismProgram;
import com.chf.bbcms.evangelism.domain.EvangelismProgramType;
import com.chf.bbcms.evangelism.domain.EvangelismRecord;
import com.chf.bbcms.evangelism.domain.EvangelismRecorded;
import com.chf.bbcms.shared.domain.NotFoundException;
import com.chf.bbcms.shared.outbox.DomainEventBus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class EvangelismService implements ManageEvangelismUseCase {

    private final EvangelismProgramRepository programRepository;
    private final EvangelismRecordRepository recordRepository;
    private final DomainEventBus eventBus;
    private final TransactionalOperator txOperator;

    public EvangelismService(EvangelismProgramRepository programRepository,
                             EvangelismRecordRepository recordRepository,
                             DomainEventBus eventBus,
                             TransactionalOperator txOperator) {
        this.programRepository = programRepository;
        this.recordRepository = recordRepository;
        this.eventBus = eventBus;
        this.txOperator = txOperator;
    }

    @Override
    public Mono<EvangelismProgram> draftProgram(String title, EvangelismProgramType type, int objective) {
        return programRepository.save(EvangelismProgram.draft(title, type, objective));
    }

    @Override
    public Mono<EvangelismProgram> addProgramDate(UUID programId, LocalDate date) {
        return loadProgram(programId).flatMap(p -> { p.addDate(date); return programRepository.save(p); });
    }

    @Override
    public Mono<EvangelismProgram> addProgramBibleClub(UUID programId, UUID bibleClubId) {
        return loadProgram(programId).flatMap(p -> { p.addBibleClub(bibleClubId); return programRepository.save(p); });
    }

    @Override
    public Mono<EvangelismProgram> activateProgram(UUID programId) {
        return loadProgram(programId).flatMap(p -> { p.activate(); return programRepository.save(p); });
    }

    @Override
    public Mono<EvangelismProgram> closeProgram(UUID programId) {
        return loadProgram(programId).flatMap(p -> { p.close(); return programRepository.save(p); });
    }

    @Override
    public Mono<EvangelismProgram> findProgramById(UUID programId) { return loadProgram(programId); }

    @Override
    public Flux<EvangelismProgram> listPrograms() { return programRepository.findAll(); }

    @Override
    public Mono<EvangelismRecord> recordSession(RecordSessionCommand cmd) {
        return loadProgram(cmd.programId())
                .flatMap(program -> {
                    program.validateRecordDate(cmd.date()); // RM-06
                    program.aggregate(cmd.preached(), cmd.believed(), cmd.encouraged());
                    EvangelismRecord r = EvangelismRecord.create(cmd.programId(), cmd.date(),
                            cmd.preached(), cmd.believed(), cmd.encouraged(),
                            cmd.tracts(), cmd.savedContacts(), cmd.notes(),
                            cmd.participantMemberIds());
                    return programRepository.save(program)
                            .then(recordRepository.save(r))
                            .flatMap(saved -> eventBus.publish(new EvangelismRecorded(
                                            saved.getId(), saved.getProgramId(),
                                            List.copyOf(saved.getParticipantMemberIds()),
                                            Instant.now()))
                                    .thenReturn(saved));
                })
                .as(txOperator::transactional);
    }

    @Override
    public Flux<EvangelismRecord> listRecordsByProgram(UUID programId) {
        return recordRepository.findByProgram(programId);
    }

    private Mono<EvangelismProgram> loadProgram(UUID id) {
        return programRepository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("EvangelismProgram", id)));
    }
}
