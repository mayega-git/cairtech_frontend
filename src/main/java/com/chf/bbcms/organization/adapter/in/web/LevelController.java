package com.chf.bbcms.organization.adapter.in.web;

import com.chf.bbcms.organization.application.port.in.ManageLevelUseCase;
import com.chf.bbcms.organization.domain.Level;
import com.chf.bbcms.organization.domain.LevelType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/bible-clubs/{bibleClubId}/levels")
public class LevelController {

    private final ManageLevelUseCase useCase;

    public LevelController(ManageLevelUseCase useCase) {
        this.useCase = useCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:level:create')")
    public Mono<LevelResponse> create(@PathVariable UUID bibleClubId,
                                      @Valid @RequestBody CreateLevelRequest req) {
        return useCase.create(bibleClubId, req.name(), req.profile(), req.type())
                .map(LevelResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:level:read')")
    public Flux<LevelResponse> list(@PathVariable UUID bibleClubId) {
        return useCase.listByBibleClub(bibleClubId).map(LevelResponse::from);
    }

    @PutMapping("/{levelId}")
    @PreAuthorize("hasAuthority('bbcms:level:update')")
    public Mono<LevelResponse> rename(@PathVariable UUID levelId,
                                      @Valid @RequestBody RenameRequest req) {
        return useCase.rename(levelId, req.name()).map(LevelResponse::from);
    }

    @PutMapping("/{levelId}/president")
    @PreAuthorize("hasAuthority('bbcms:level:update')")
    public Mono<LevelResponse> assignPresident(@PathVariable UUID levelId,
                                               @Valid @RequestBody AssignMemberRequest req) {
        return useCase.assignPresident(levelId, req.memberId()).map(LevelResponse::from);
    }

    @DeleteMapping("/{levelId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('bbcms:level:delete')")
    public Mono<Void> delete(@PathVariable UUID levelId) {
        return useCase.deleteById(levelId);
    }

    public record CreateLevelRequest(@NotBlank String name, String profile, @NotNull LevelType type) {}
    public record RenameRequest(@NotBlank String name) {}
    public record AssignMemberRequest(@NotNull UUID memberId) {}

    public record LevelResponse(UUID id, UUID bibleClubId, String name, String profile, String type,
                                UUID presidentMemberId, UUID vicePresidentMemberId) {
        static LevelResponse from(Level l) {
            return new LevelResponse(l.getId(), l.getBibleClubId(), l.getName(), l.getProfile(),
                    l.getType().name(), l.getPresidentMemberId(), l.getVicePresidentMemberId());
        }
    }
}
