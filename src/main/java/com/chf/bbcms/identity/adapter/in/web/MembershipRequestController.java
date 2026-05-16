package com.chf.bbcms.identity.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.identity.application.port.in.ManageMembershipUseCase;
import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import jakarta.validation.Valid;
import org.springframework.r2dbc.core.DatabaseClient;
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
    private final DatabaseClient client;

    public MembershipRequestController(ManageMembershipUseCase useCase, DatabaseClient client) {
        this.useCase = useCase;
        this.client = client;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:membership-request:read')")
    public Flux<MembershipRequestResponse> list(
            @RequestParam(value = "status", defaultValue = "PENDING") MembershipRequestStatus status) {
        return useCase.listByStatus(status).map(MembershipRequestResponse::from);
    }

    /**
     * Liste enrichie avec les PII du UserAccount (utile pour l'écran
     * "Demandes d'adhésion" côté leader).
     */
    @GetMapping("/with-profile")
    @PreAuthorize("hasAuthority('bbcms:membership-request:read')")
    public Flux<MembershipRequestWithProfileResponse> listWithProfile(
            @RequestParam(value = "status", defaultValue = "PENDING") MembershipRequestStatus status) {
        return client.sql("""
                SELECT r.id, r.user_account_id, r.requested_type, r.bible_club_id, r.level_id,
                       r.profession, r.status, r.decision_by, r.decision_at, r.decision_comment,
                       r.created_at,
                       u.email, u.first_names, u.next_names, u.gender, u.date_of_birth,
                       u.picture_file_id, u.phone
                  FROM bbcms_membership_request r
                  JOIN bbcms_user_account u ON u.id = r.user_account_id
                 WHERE r.status = :status
                 ORDER BY r.created_at DESC
                """)
                .bind("status", status.name())
                .map((row, meta) -> new MembershipRequestWithProfileResponse(
                        row.get("id", UUID.class),
                        row.get("user_account_id", UUID.class),
                        row.get("requested_type", String.class),
                        row.get("bible_club_id", UUID.class),
                        row.get("level_id", UUID.class),
                        row.get("profession", String.class),
                        row.get("status", String.class),
                        row.get("decision_by", UUID.class),
                        row.get("decision_at", Instant.class),
                        row.get("decision_comment", String.class),
                        row.get("created_at", Instant.class),
                        row.get("email", String.class),
                        row.get("first_names", String.class),
                        row.get("next_names", String.class),
                        row.get("gender", String.class),
                        row.get("date_of_birth", java.time.LocalDate.class),
                        row.get("picture_file_id", UUID.class),
                        row.get("phone", String.class)))
                .all();
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

    public record MembershipRequestWithProfileResponse(
            UUID id, UUID userAccountId, String requestedType,
            UUID bibleClubId, UUID levelId, String profession,
            String status, UUID decisionBy, Instant decisionAt, String decisionComment,
            Instant createdAt,
            String email, String firstNames, String nextNames, String gender,
            java.time.LocalDate dateOfBirth, UUID pictureFileId, String phone) {}
}
