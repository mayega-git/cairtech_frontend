package com.chf.bbcms.attendance.adapter.in.web;

import com.chf.bbcms.attendance.application.port.in.AttendanceUseCase;
import com.chf.bbcms.attendance.domain.AcademicYears;
import com.chf.bbcms.attendance.domain.AttendanceScore;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/attendance")
public class AttendanceController {

    private final AttendanceUseCase useCase;

    public AttendanceController(AttendanceUseCase useCase) { this.useCase = useCase; }

    @GetMapping("/members/{memberId}")
    @PreAuthorize("hasAuthority('bbcms:faithfulness:read')")
    public Mono<AttendanceScoreResponse> getScore(@PathVariable UUID memberId,
                                                  @RequestParam(required = false) Integer academicYear) {
        int year = academicYear == null ? AcademicYears.current() : academicYear;
        return useCase.findScoreByMemberAndYear(memberId, year).map(AttendanceScoreResponse::from);
    }

    @PostMapping("/members/{memberId}/recompute")
    @PreAuthorize("hasAuthority('bbcms:faithfulness:compute')")
    public Mono<AttendanceScoreResponse> recompute(@PathVariable UUID memberId) {
        return useCase.recomputeForMember(memberId).map(AttendanceScoreResponse::from);
    }

    @GetMapping("/bible-clubs/{bibleClubId}/faithful")
    @PreAuthorize("hasAuthority('bbcms:faithfulness:read')")
    public Flux<AttendanceScoreResponse> faithfulOf(@PathVariable UUID bibleClubId,
                                                    @RequestParam(required = false) Integer academicYear) {
        int year = academicYear == null ? AcademicYears.current() : academicYear;
        return useCase.listFaithfulByBibleClub(bibleClubId, year).map(AttendanceScoreResponse::from);
    }

    @PostMapping("/recompute-all")
    @PreAuthorize("hasAuthority('bbcms:faithfulness:compute')")
    public Mono<RecomputeAllResponse> recomputeAll() {
        return useCase.recomputeAllFaithfulness().map(RecomputeAllResponse::new);
    }

    public record AttendanceScoreResponse(UUID id, UUID memberId, UUID bibleClubId, UUID levelId,
                                          int academicYear, int score, int totalEligible,
                                          BigDecimal faithfulPercentage, boolean faithful,
                                          Instant lastComputedAt) {
        static AttendanceScoreResponse from(AttendanceScore s) {
            return new AttendanceScoreResponse(s.getId(), s.getMemberId(), s.getBibleClubId(),
                    s.getLevelId(), s.getAcademicYear(), s.getScore(), s.getTotalEligible(),
                    s.getFaithfulPercentage(), s.isFaithful(), s.getLastComputedAt());
        }
    }

    public record RecomputeAllResponse(long studentsProcessed) {}
}
