package com.chf.bbcms.people.adapter.in.web;

import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

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
}
