package com.chf.bbcms.intercession.adapter.in.web;

import com.chf.bbcms.intercession.application.port.in.ManageIntercessionUseCase;
import com.chf.bbcms.intercession.domain.PrayerChain;
import com.chf.bbcms.intercession.domain.PrayerSlot;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/intercession")
public class IntercessionController {

    private final ManageIntercessionUseCase useCase;

    public IntercessionController(ManageIntercessionUseCase useCase) { this.useCase = useCase; }

    @PostMapping("/chains")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<ChainResponse> draftChain(@Valid @RequestBody DraftChainRequest req) {
        return useCase.draftChain(req.bibleClubId(), req.title(), req.dateStart(), req.dateEnd())
                .map(ChainResponse::from);
    }

    @PostMapping("/chains/{id}/start")
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<ChainResponse> start(@PathVariable UUID id) {
        return useCase.startChain(id).map(ChainResponse::from);
    }

    @PostMapping("/chains/{id}/close")
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<ChainResponse> close(@PathVariable UUID id) {
        return useCase.closeChain(id).map(ChainResponse::from);
    }

    @GetMapping("/bible-clubs/{bibleClubId}/chains")
    @PreAuthorize("hasAuthority('bbcms:intercession:read')")
    public Flux<ChainResponse> list(@PathVariable UUID bibleClubId) {
        return useCase.listByBibleClub(bibleClubId).map(ChainResponse::from);
    }

    @PostMapping("/chains/{chainId}/slots")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<SlotResponse> addSlot(@PathVariable UUID chainId, @Valid @RequestBody SlotRequest req) {
        return useCase.addSlot(chainId, req.start(), req.end()).map(SlotResponse::from);
    }

    @PostMapping("/slots/{slotId}/cover")
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<SlotResponse> cover(@PathVariable UUID slotId, @Valid @RequestBody CoverRequest req) {
        return useCase.coverSlot(slotId, req.intercessorMemberId(), req.note()).map(SlotResponse::from);
    }

    @PostMapping("/slots/{slotId}/uncover")
    @PreAuthorize("hasAuthority('bbcms:intercession:chain-manage')")
    public Mono<SlotResponse> uncover(@PathVariable UUID slotId) {
        return useCase.uncoverSlot(slotId).map(SlotResponse::from);
    }

    @GetMapping("/chains/{chainId}/slots")
    @PreAuthorize("hasAuthority('bbcms:intercession:read')")
    public Flux<SlotResponse> listSlots(@PathVariable UUID chainId) {
        return useCase.listSlotsByChain(chainId).map(SlotResponse::from);
    }

    public record DraftChainRequest(@NotNull UUID bibleClubId, @NotBlank String title,
                                    @NotNull LocalDate dateStart, LocalDate dateEnd) {}
    public record SlotRequest(@NotNull Instant start, @NotNull Instant end) {}
    public record CoverRequest(@NotNull UUID intercessorMemberId, String note) {}

    public record ChainResponse(UUID id, UUID bibleClubId, String title,
                                LocalDate dateStart, LocalDate dateEnd, String status) {
        static ChainResponse from(PrayerChain c) {
            return new ChainResponse(c.getId(), c.getBibleClubId(), c.getTitle(),
                    c.getDateStart(), c.getDateEnd(), c.getStatus().name());
        }
    }

    public record SlotResponse(UUID id, UUID prayerChainId, UUID intercessorMemberId,
                               Instant dtStart, Instant dtEnd, boolean covered, String note) {
        static SlotResponse from(PrayerSlot s) {
            return new SlotResponse(s.getId(), s.getPrayerChainId(),
                    s.getIntercessorMemberId().orElse(null),
                    s.getDtStart(), s.getDtEnd(), s.isCovered(), s.getNote());
        }
    }
}
