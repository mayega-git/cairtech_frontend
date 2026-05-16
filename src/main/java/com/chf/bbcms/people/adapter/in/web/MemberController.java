package com.chf.bbcms.people.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.application.port.in.MemberWithProfile;
import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;

import java.math.BigDecimal;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/members")
public class MemberController {

    private final ManageMemberUseCase useCase;

    public MemberController(ManageMemberUseCase useCase) {
        this.useCase = useCase;
    }

    /**
     * Profil "member" de l'utilisateur authentifié. Renvoie 404 si le compte
     * n'est rattaché à aucun Member (visiteur en attente d'approbation).
     */
    @GetMapping("/me")
    public Mono<MemberResponse> me() {
        return ReactiveSecurityContextHolder.getContext()
                .map(ctx -> ((BbcmsAuthenticationToken) ctx.getAuthentication()).getUserId())
                .flatMap(useCase::findByUserAccount)
                .map(MemberResponse::from);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:member:read')")
    public Mono<MemberResponse> get(@PathVariable UUID id) {
        return useCase.findById(id).map(MemberResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:member:read')")
    public Flux<MemberResponse> listByBibleClub(@RequestParam("bibleClubId") UUID bibleClubId) {
        return useCase.listByBibleClub(bibleClubId).map(MemberResponse::from);
    }

    /** Annuaire enrichi (member + PII de l'UserAccount) — utilisé par l'UI. */
    @GetMapping("/with-profile")
    @PreAuthorize("hasAuthority('bbcms:member:read')")
    public Flux<MemberWithProfileResponse> listWithProfile(@RequestParam("bibleClubId") UUID bibleClubId) {
        return useCase.listByBibleClubWithProfile(bibleClubId).map(MemberWithProfileResponse::from);
    }

    @GetMapping("/{id}/with-profile")
    @PreAuthorize("hasAuthority('bbcms:member:read')")
    public Mono<MemberWithProfileResponse> getWithProfile(@PathVariable UUID id) {
        return useCase.findByIdWithProfile(id).map(MemberWithProfileResponse::from);
    }

    @PutMapping("/{id}/level")
    @PreAuthorize("hasAuthority('bbcms:member:transfer')")
    public Mono<MemberResponse> transferLevel(@PathVariable UUID id,
                                              @Valid @RequestBody TransferLevelRequest req) {
        return useCase.transferLevel(id, req.newLevelId()).map(MemberResponse::from);
    }

    @PutMapping("/{id}/bible-club")
    @PreAuthorize("hasAuthority('bbcms:member:transfer')")
    public Mono<MemberResponse> transferBbc(@PathVariable UUID id,
                                            @Valid @RequestBody TransferBbcRequest req) {
        return useCase.transferBibleClub(id, req.newBibleClubId(), req.newLevelId())
                .map(MemberResponse::from);
    }

    @PostMapping("/{id}/departments")
    @PreAuthorize("hasAuthority('bbcms:member:update')")
    public Mono<MemberResponse> addDepartment(@PathVariable UUID id,
                                              @Valid @RequestBody DepartmentRequest req) {
        return useCase.addDepartment(id, req.department()).map(MemberResponse::from);
    }

    @DeleteMapping("/{id}/departments/{dept}")
    @PreAuthorize("hasAuthority('bbcms:member:update')")
    public Mono<MemberResponse> removeDepartment(@PathVariable UUID id, @PathVariable("dept") Department dept) {
        return useCase.removeDepartment(id, dept).map(MemberResponse::from);
    }

    @PostMapping("/{id}/leave")
    @PreAuthorize("hasAuthority('bbcms:member:leave')")
    public Mono<MemberResponse> leave(@PathVariable UUID id) {
        return useCase.leave(id).map(MemberResponse::from);
    }

    public record TransferLevelRequest(@NotNull UUID newLevelId) {}
    public record TransferBbcRequest(@NotNull UUID newBibleClubId, @NotNull UUID newLevelId) {}
    public record DepartmentRequest(@NotNull Department department) {}

    public record MemberResponse(
            UUID id, UUID userAccountId, String kind, UUID bibleClubId, UUID levelId,
            int participationScore, BigDecimal faithfulPercentage,
            String profession, String professionalPosition, String status,
            Set<Department> departments
    ) {
        static MemberResponse from(Member m) {
            return new MemberResponse(
                    m.getId(), m.getUserAccountId(), m.getKind().name(),
                    m.getBibleClubId().orElse(null), m.getLevelId().orElse(null),
                    m.getParticipationScore(), m.getFaithfulPercentage(),
                    m.getProfession(),
                    m.getProfessionalPosition() == null ? null : m.getProfessionalPosition().name(),
                    m.getStatus().name(), m.getDepartments());
        }
    }

    public record MemberWithProfileResponse(
            UUID id, UUID userAccountId, String kind, UUID bibleClubId, UUID levelId,
            int participationScore, BigDecimal faithfulPercentage,
            String profession, String professionalPosition, String status,
            Set<Department> departments,
            // PII
            String email, String firstNames, String nextNames, String gender,
            LocalDate dateOfBirth, UUID pictureFileId,
            String accountStatus, String userType
    ) {
        static MemberWithProfileResponse from(MemberWithProfile p) {
            return new MemberWithProfileResponse(
                    p.memberId(), p.userAccountId(), p.kind(),
                    p.bibleClubId(), p.levelId(),
                    p.participationScore(), p.faithfulPercentage(),
                    p.profession(), p.professionalPosition(),
                    p.memberStatus(), p.departments(),
                    p.email(), p.firstNames(), p.nextNames(),
                    p.gender(), p.dateOfBirth(), p.pictureFileId(),
                    p.accountStatus(), p.userType());
        }
    }
}
