package com.chf.bbcms.reset.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.reset.application.port.in.ResetBibleClubUseCase;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/bible-clubs")
public class ResetController {

    private final ResetBibleClubUseCase useCase;

    public ResetController(ResetBibleClubUseCase useCase) { this.useCase = useCase; }

    @PostMapping("/{id}/reset")
    @PreAuthorize("hasAuthority('bbcms:bible-club:reset')")
    public Mono<ResetSnapshotResponse> reset(@PathVariable UUID id, @Valid @RequestBody ResetRequest req) {
        return ReactiveSecurityContextHolder.getContext()
                .map(ctx -> ((BbcmsAuthenticationToken) ctx.getAuthentication()).getUserId())
                .flatMap(actorId -> useCase.reset(id, req.academicYear(), actorId))
                .map(ResetSnapshotResponse::from);
    }

    public record ResetRequest(@Min(2024) int academicYear) {}

    public record ResetSnapshotResponse(UUID id, UUID bibleClubId, int academicYear,
                                        int nbMembersBefore, int nbFaithfulBefore, int nbMeetings,
                                        BigDecimal percentageReached, Instant archivedAt,
                                        UUID archiveFileId) {
        static ResetSnapshotResponse from(BibleClubResetSnapshot s) {
            return new ResetSnapshotResponse(s.id(), s.bibleClubId(), s.academicYear(),
                    s.nbMembersBefore(), s.nbFaithfulBefore(), s.nbMeetings(),
                    s.percentageReached(), s.archivedAt(), s.archiveFileId());
        }
    }
}
