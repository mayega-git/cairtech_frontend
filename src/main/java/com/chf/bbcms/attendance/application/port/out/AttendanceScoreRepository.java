package com.chf.bbcms.attendance.application.port.out;

import com.chf.bbcms.attendance.domain.AttendanceScore;
import com.chf.bbcms.attendance.domain.FaithfulnessRecord;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface AttendanceScoreRepository {
    Mono<AttendanceScore> findByMemberAndYear(UUID memberId, int academicYear);
    Flux<AttendanceScore> findByBibleClubAndYear(UUID bibleClubId, int academicYear);
    Mono<AttendanceScore> save(AttendanceScore score);
    Mono<Void> resetByBibleClubAndYear(UUID bibleClubId, int academicYear);

    /** Insert idempotent (ON CONFLICT DO NOTHING). Renvoie true si insertion effective. */
    Mono<Boolean> tryAddRecord(FaithfulnessRecord record);
}
