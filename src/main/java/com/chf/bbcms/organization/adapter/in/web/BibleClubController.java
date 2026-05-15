package com.chf.bbcms.organization.adapter.in.web;

import com.chf.bbcms.organization.application.port.in.ManageBibleClubUseCase;
import com.chf.bbcms.organization.application.port.in.ManageBibleClubUseCase.CreateBibleClubCommand;
import com.chf.bbcms.organization.domain.BibleClub;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/bible-clubs")
public class BibleClubController {

    private final ManageBibleClubUseCase useCase;

    public BibleClubController(ManageBibleClubUseCase useCase) {
        this.useCase = useCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:bible-club:create')")
    public Mono<BibleClubResponse> create(@Valid @RequestBody CreateRequest req) {
        return useCase.create(new CreateBibleClubCommand(
                        req.name(), req.profile(), req.schoolName(),
                        req.goalNbFaithful(), req.dateCreated()))
                .map(BibleClubResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:bible-club:read') or hasAuthority('bbcms:bible-club:read-partial')")
    public Flux<BibleClubResponse> list() {
        return useCase.listAll().map(BibleClubResponse::from);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:bible-club:read') or hasAuthority('bbcms:bible-club:read-partial')")
    public Mono<BibleClubResponse> get(@PathVariable UUID id) {
        return useCase.findById(id).map(BibleClubResponse::from);
    }

    @PutMapping("/{id}/goal")
    @PreAuthorize("hasAuthority('bbcms:bible-club:set-goal')")
    public Mono<BibleClubResponse> setGoal(@PathVariable UUID id, @Valid @RequestBody SetGoalRequest req) {
        return useCase.setGoal(id, req.goalNbFaithful()).map(BibleClubResponse::from);
    }

    @PutMapping("/{id}/triumvirate")
    @PreAuthorize("hasAuthority('bbcms:bible-club:assign-leader')")
    public Mono<BibleClubResponse> assignTriumvirate(@PathVariable UUID id,
                                                     @Valid @RequestBody AssignTriumvirateRequest req) {
        return useCase.assignTriumvirate(id, req.presidentId(), req.vicePresidentId(), req.secretaryId())
                .map(BibleClubResponse::from);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('bbcms:bible-club:delete')")
    public Mono<Void> delete(@PathVariable UUID id) {
        return useCase.deleteById(id);
    }

    public record CreateRequest(
            @NotBlank String name, String profile, String schoolName,
            @Min(0) Integer goalNbFaithful, LocalDate dateCreated) {}

    public record SetGoalRequest(@Min(0) int goalNbFaithful) {}

    public record AssignTriumvirateRequest(UUID presidentId, UUID vicePresidentId, UUID secretaryId) {}

    public record BibleClubResponse(UUID id, String name, String profile, String schoolName,
                                    Integer goalNbFaithful, LocalDate dateCreated, String status,
                                    UUID presidentMemberId, UUID vicePresidentMemberId, UUID secretaryMemberId) {
        static BibleClubResponse from(BibleClub b) {
            return new BibleClubResponse(b.getId(), b.getName(), b.getProfile(), b.getSchoolName(),
                    b.getGoalNbFaithful(), b.getDateCreated(), b.getStatus().name(),
                    b.getPresidentMemberId(), b.getVicePresidentMemberId(), b.getSecretaryMemberId());
        }
    }
}
