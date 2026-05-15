package com.chf.bbcms.discipleship.application.service;

import com.chf.bbcms.discipleship.application.port.in.ManageDiscipleshipUseCase;
import com.chf.bbcms.discipleship.application.port.out.DiscipleLinkRepository;
import com.chf.bbcms.discipleship.application.port.out.DiscipleshipRecordRepository;
import com.chf.bbcms.discipleship.domain.DiscipleLink;
import com.chf.bbcms.discipleship.domain.DiscipleshipRecord;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@Service
public class DiscipleshipService implements ManageDiscipleshipUseCase {

    private final DiscipleLinkRepository linkRepository;
    private final DiscipleshipRecordRepository recordRepository;

    public DiscipleshipService(DiscipleLinkRepository linkRepository,
                               DiscipleshipRecordRepository recordRepository) {
        this.linkRepository = linkRepository;
        this.recordRepository = recordRepository;
    }

    @Override
    public Mono<DiscipleLink> assignDisciple(UUID makerId, UUID discipleId) {
        return linkRepository.save(DiscipleLink.assign(makerId, discipleId));
    }

    @Override
    public Mono<DiscipleLink> endDiscipleLink(UUID linkId, LocalDate when) {
        return linkRepository.findById(linkId)
                .switchIfEmpty(Mono.error(new NotFoundException("DiscipleLink", linkId)))
                .flatMap(l -> { l.end(when); return linkRepository.save(l); });
    }

    @Override
    public Flux<DiscipleLink> listActiveByMaker(UUID makerId) {
        return linkRepository.findActiveByMaker(makerId);
    }

    @Override
    public Mono<DiscipleshipRecord> recordSession(RecordSessionCommand cmd) {
        DiscipleshipRecord r = DiscipleshipRecord.create(cmd.makerId(), cmd.meetingId(),
                cmd.dateOccurred(), cmd.startTime(), cmd.endTime(),
                cmd.theme(), cmd.location(), cmd.description(),
                cmd.disciplesState(), cmd.investment(), cmd.presentDiscipleIds());
        return recordRepository.save(r);
    }

    @Override
    public Flux<DiscipleshipRecord> listByMaker(UUID makerId) {
        return recordRepository.findByMaker(makerId);
    }
}
