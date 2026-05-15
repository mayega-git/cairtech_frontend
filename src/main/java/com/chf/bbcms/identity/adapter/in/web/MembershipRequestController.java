package com.chf.bbcms.identity.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.identity.application.port.in.ManageMembershipUseCase;
import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/membership-requests")
public class MembershipRequestController {

    private final ManageMembershipUseCase useCase;

    public MembershipRequestController(ManageMembershipUseCase useCase) {
        this.useCase = useCase;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:membership-request:read')")
    public Flux<MembershipRequestResponse> list(
            @RequestParam(value = "status", defaultValue = "PENDING") MembershipRequestStatus status) {
        return useCase.listByStatus(status).map(MembershipRequestResponse::from);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:membership-request:read')")
    public Mono<MembershipRequestResponse> get(@PathVariable UUID id) {
        return useCase.findById(id).map(MembershipRequestResponse::from);
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasAuthority('bbcms:membership-request:approve')")
    public Mono<MembershipRequestResponse> approve(@PathVariable UUID id,
                                                   @Valid @RequestBody ApproveRequest req) {
        return currentUserId().flatMap(approverId ->
                useCase.approve(id, approverId, req.assignedBibleClubId(), req.assignedLevelId(), req.comment()))
                .map(MembershipRequestResponse::from);
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasAuthority('bbcms:membership-request:reject')")
    public Mono<MembershipRequestResponse> reject(@PathVariable UUID id,
                                                  @Valid @RequestBody RejectRequest req) {
        return currentUserId().flatMap(approverId -> useCase.reject(id, approverId, req.comment()))
                .map(MembershipRequestResponse::from);
    }

    @PostMapping("/{id}/cancel")
    public Mono<MembershipRequestResponse> cancel(@PathVariable UUID id) {
        return useCase.cancel(id).map(MembershipRequestResponse::from);
    }

    private Mono<UUID> currentUserId() {
        return ReactiveSecurityContextHolder.getContext()
                .map(ctx -> ((BbcmsAuthenticationToken) ctx.getAuthentication()).getUserId());
    }

    public record ApproveRequest(UUID assignedBibleClubId, UUID assignedLevelId, String comment) {}
    public record RejectRequest(String comment) {}

    public record MembershipRequestResponse(UUID id, UUID userAccountId, String requestedType,
                                            UUID bibleClubId, UUID levelId, String profession,
                                            String status, UUID decisionBy, Instant decisionAt,
                                            String decisionComment) {
        static MembershipRequestResponse from(MembershipRequest r) {
            return new MembershipRequestResponse(r.getId(), r.getUserAccountId(),
                    r.getRequestedType().name(),
                    r.getBibleClubId().orElse(null), r.getLevelId().orElse(null),
                    r.getProfession(), r.getStatus().name(),
                    r.getDecisionBy(), r.getDecisionAt(), r.getDecisionComment());
        }
    }
}
