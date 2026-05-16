package com.chf.bbcms.meeting.application.service;

import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase;
import com.chf.bbcms.meeting.application.port.out.MeetingRepository;
import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingPicture;
import com.chf.bbcms.meeting.domain.MeetingPresence;
import com.chf.bbcms.meeting.domain.MeetingRecorded;
import com.chf.bbcms.shared.domain.NotFoundException;
import com.chf.bbcms.shared.outbox.DomainEventBus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Service
public class MeetingService implements ManageMeetingUseCase {

    private final MeetingRepository repository;
    private final DomainEventBus eventBus;
    private final TransactionalOperator txOperator;

    public MeetingService(MeetingRepository repository, DomainEventBus eventBus,
                          TransactionalOperator txOperator) {
        this.repository = repository;
        this.eventBus = eventBus;
        this.txOperator = txOperator;
    }

    @Override
    public Mono<Meeting> plan(PlanMeetingCommand cmd) {
        Meeting m = Meeting.plan(cmd.title(), cmd.type(), cmd.bibleClubId(), cmd.levelId(),
                cmd.plannedDate(), cmd.plannedStartTime(), cmd.plannedEndTime(),
                cmd.maxPictures() == null ? 20 : cmd.maxPictures());
        if (cmd.teacherMemberId() != null) m.setTeacher(cmd.teacherMemberId());
        return repository.save(m);
    }

    @Override
    public Mono<Meeting> start(UUID meetingId, LocalDate dateOccurred, LocalTime startTime) {
        return load(meetingId).flatMap(m -> { m.start(dateOccurred, startTime); return repository.save(m); });
    }

    @Override
    public Mono<Meeting> end(UUID meetingId, LocalTime endTime) {
        return load(meetingId).flatMap(m -> { m.end(endTime); return repository.save(m); });
    }

    @Override
    public Mono<Meeting> record(RecordMeetingCommand cmd) {
        return load(cmd.meetingId())
                .flatMap(meeting -> {
                    int picCount = cmd.pictures() == null ? 0 : cmd.pictures().size();
                    meeting.record(cmd.dateOccurred(), cmd.startTime(), cmd.endTime(),
                            cmd.nbBelievers(), cmd.summary(), picCount);

                    List<MeetingPresence> presences = cmd.presents() == null ? List.of()
                            : cmd.presents().stream().map(p ->
                                p.memberId() != null
                                    ? MeetingPresence.ofMember(meeting.getId(), p.memberId(), p.role())
                                    : MeetingPresence.ofVisitor(meeting.getId(), p.visitorId(), p.role()))
                            .toList();

                    List<MeetingPicture> pictures = cmd.pictures() == null ? List.of()
                            : cmd.pictures().stream().map(p -> MeetingPicture.create(meeting.getId(), p.fileId(), p.caption())).toList();

                    List<UUID> presentMemberIds = presences.stream()
                            .filter(MeetingPresence::isMember)
                            .map(p -> p.getMemberId().orElseThrow())
                            .toList();

                    return repository.save(meeting)
                            .flatMap(saved -> repository.savePresences(saved.getId(), presences)
                                    .then(repository.savePictures(saved.getId(), pictures))
                                    .then(eventBus.publish(MeetingRecorded.of(saved, presentMemberIds)))
                                    .thenReturn(saved));
                })
                .as(txOperator::transactional);
    }

    @Override
    public Mono<Meeting> cancel(UUID meetingId) {
        return load(meetingId).flatMap(m -> { m.cancel(); return repository.save(m); });
    }

    @Override
    public Mono<Meeting> findById(UUID meetingId) { return load(meetingId); }

    @Override
    public reactor.core.publisher.Flux<Meeting> listByBibleClub(UUID bibleClubId) {
        return repository.findByBibleClub(bibleClubId);
    }

    @Override
    public reactor.core.publisher.Flux<com.chf.bbcms.meeting.domain.MeetingPresence> listPresences(UUID meetingId) {
        return repository.findPresences(meetingId);
    }

    @Override
    public reactor.core.publisher.Flux<com.chf.bbcms.meeting.domain.MeetingPicture> listPictures(UUID meetingId) {
        return repository.findPictures(meetingId);
    }

    private Mono<Meeting> load(UUID id) {
        return repository.findById(id).switchIfEmpty(Mono.error(new NotFoundException("Meeting", id)));
    }
}
