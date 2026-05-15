package com.chf.bbcms.attendance.application.service;

import com.chf.bbcms.attendance.application.port.in.AttendanceUseCase;
import com.chf.bbcms.attendance.application.port.out.AttendanceScoreRepository;
import com.chf.bbcms.attendance.application.port.out.InactivityWatchRepository;
import com.chf.bbcms.attendance.domain.AcademicYears;
import com.chf.bbcms.attendance.domain.AttendanceScore;
import com.chf.bbcms.attendance.domain.FaithfulnessRecord;
import com.chf.bbcms.attendance.domain.FaithfulnessSource;
import com.chf.bbcms.attendance.domain.InactivityWatch;
import com.chf.bbcms.event.application.port.out.EventRepository;
import com.chf.bbcms.meeting.application.port.out.MeetingRepository;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.MemberKind;
import com.chf.bbcms.shared.domain.NotFoundException;
import com.chf.bbcms.shared.outbox.DomainEventBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Service
public class AttendanceService implements AttendanceUseCase {

    private static final Logger log = LoggerFactory.getLogger(AttendanceService.class);
    private static final int DEFAULT_INACTIVITY_THRESHOLD = 90;

    private final AttendanceScoreRepository scoreRepository;
    private final InactivityWatchRepository inactivityRepository;
    private final MemberRepository memberRepository;
    private final MeetingRepository meetingRepository;
    private final EventRepository eventRepository;
    private final FaithfulnessEngine engine;
    private final DomainEventBus eventBus;

    public AttendanceService(AttendanceScoreRepository scoreRepository,
                             InactivityWatchRepository inactivityRepository,
                             MemberRepository memberRepository,
                             MeetingRepository meetingRepository,
                             EventRepository eventRepository,
                             FaithfulnessEngine engine,
                             DomainEventBus eventBus) {
        this.scoreRepository = scoreRepository;
        this.inactivityRepository = inactivityRepository;
        this.memberRepository = memberRepository;
        this.meetingRepository = meetingRepository;
        this.eventRepository = eventRepository;
        this.engine = engine;
        this.eventBus = eventBus;
    }

    @Override
    public Mono<AttendanceScore> recordPresence(UUID memberId, FaithfulnessSource source,
                                                UUID meetingId, UUID eventId, UUID evangelismRecordId) {
        return memberRepository.findById(memberId)
                .switchIfEmpty(Mono.error(new NotFoundException("Member", memberId)))
                .flatMap(member -> {
                    if (member.getKind() != MemberKind.STUDENT) return Mono.empty();
                    int year = AcademicYears.current();
                    return getOrCreateScore(member, year)
                            .flatMap(score -> engine.weightFor(source).flatMap(weight -> {
                                FaithfulnessRecord rec = switch (source) {
                                    case MEETING -> FaithfulnessRecord.forMeeting(score.getId(), memberId, meetingId, weight);
                                    case EVENT -> FaithfulnessRecord.forEvent(score.getId(), memberId, eventId, weight);
                                    case EVANGELISM -> FaithfulnessRecord.forEvangelism(score.getId(), memberId, evangelismRecordId, weight);
                                };
                                return scoreRepository.tryAddRecord(rec).flatMap(inserted -> {
                                    if (Boolean.TRUE.equals(inserted)) score.incrementBy(weight);
                                    return updateInactivity(memberId).then(scoreRepository.save(score));
                                });
                            }));
                });
    }

    @Override
    public Mono<Long> recomputeAllFaithfulness() {
        return memberRepository.findActiveStudents()
                .flatMap(member -> recomputeForMember(member.getId())
                        .onErrorResume(ex -> {
                            log.warn("Failed to recompute faithfulness for member {}: {}",
                                    member.getId(), ex.getMessage());
                            return Mono.empty();
                        }))
                .count()
                .doOnSuccess(n -> log.info("Faithfulness recomputed for {} student(s)", n));
    }

    @Override
    public Mono<AttendanceScore> recomputeForMember(UUID memberId) {
        int year = AcademicYears.current();
        return memberRepository.findById(memberId)
                .switchIfEmpty(Mono.error(new NotFoundException("Member", memberId)))
                .flatMap(member -> getOrCreateScore(member, year)
                        .flatMap(score -> meetingRepository.countEligibleForMember(
                                        memberId,
                                        member.getBibleClubId().orElse(null),
                                        member.getLevelId().orElse(null),
                                        member.getDepartments().stream().map(Enum::name).toList(),
                                        year)
                                .flatMap(eligible -> engine.recompute(score, eligible.intValue())
                                        .flatMap(scoreRepository::save))));
    }

    @Override
    public Mono<AttendanceScore> findScoreByMemberAndYear(UUID memberId, int academicYear) {
        return scoreRepository.findByMemberAndYear(memberId, academicYear)
                .switchIfEmpty(Mono.error(new NotFoundException("AttendanceScore",
                        memberId + "/" + academicYear)));
    }

    @Override
    public Flux<AttendanceScore> listFaithfulByBibleClub(UUID bibleClubId, int academicYear) {
        return scoreRepository.findByBibleClubAndYear(bibleClubId, academicYear)
                .filter(AttendanceScore::isFaithful);
    }

    private Mono<AttendanceScore> getOrCreateScore(Member member, int year) {
        return scoreRepository.findByMemberAndYear(member.getId(), year)
                .switchIfEmpty(Mono.defer(() -> scoreRepository.save(
                        AttendanceScore.initial(member.getId(),
                                member.getBibleClubId().orElse(null),
                                member.getLevelId().orElse(null),
                                year))));
    }

    private Mono<InactivityWatch> updateInactivity(UUID memberId) {
        return inactivityRepository.findByMember(memberId)
                .switchIfEmpty(Mono.defer(() -> inactivityRepository.save(
                        InactivityWatch.initial(memberId, DEFAULT_INACTIVITY_THRESHOLD))))
                .flatMap(w -> { w.recordPresence(Instant.now()); return inactivityRepository.save(w); });
    }
}
