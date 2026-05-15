package com.chf.bbcms.attendance.application.port.in;

import com.chf.bbcms.attendance.domain.AttendanceScore;
import com.chf.bbcms.attendance.domain.FaithfulnessSource;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface AttendanceUseCase {

    Mono<AttendanceScore> recordPresence(UUID memberId, FaithfulnessSource source,
                                         UUID meetingId, UUID eventId, UUID evangelismRecordId);

    /** Recalcule la fidélité de tous les étudiants actifs (cron quotidien). */
    Mono<Long> recomputeAllFaithfulness();

    Mono<AttendanceScore> recomputeForMember(UUID memberId);

    Mono<AttendanceScore> findScoreByMemberAndYear(UUID memberId, int academicYear);

    Flux<AttendanceScore> listFaithfulByBibleClub(UUID bibleClubId, int academicYear);
}
