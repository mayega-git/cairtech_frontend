package com.chf.bbcms.discipleship.adapter.in.web;

import com.chf.bbcms.discipleship.application.port.in.ManageDiscipleshipUseCase;
import com.chf.bbcms.discipleship.application.port.in.ManageDiscipleshipUseCase.RecordSessionCommand;
import com.chf.bbcms.discipleship.domain.DiscipleLink;
import com.chf.bbcms.discipleship.domain.DiscipleshipRecord;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/discipleship")
public class DiscipleshipController {

    private final ManageDiscipleshipUseCase useCase;

    public DiscipleshipController(ManageDiscipleshipUseCase useCase) { this.useCase = useCase; }

    @PostMapping("/links")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:discipleship:assign')")
    public Mono<DiscipleLinkResponse> assign(@Valid @RequestBody AssignRequest req) {
        return useCase.assignDisciple(req.makerId(), req.discipleId()).map(DiscipleLinkResponse::from);
    }

    @PostMapping("/links/{id}/end")
    @PreAuthorize("hasAuthority('bbcms:discipleship:assign')")
    public Mono<DiscipleLinkResponse> end(@PathVariable UUID id, @RequestBody EndLinkRequest req) {
        return useCase.endDiscipleLink(id, req.when()).map(DiscipleLinkResponse::from);
    }

    @GetMapping("/makers/{makerId}/disciples")
    @PreAuthorize("hasAuthority('bbcms:discipleship:read')")
    public Flux<DiscipleLinkResponse> listDisciples(@PathVariable UUID makerId) {
        return useCase.listActiveByMaker(makerId).map(DiscipleLinkResponse::from);
    }

    @PostMapping("/records")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:discipleship:record-create')")
    public Mono<RecordResponse> record(@Valid @RequestBody RecordRequest req) {
        return useCase.recordSession(new RecordSessionCommand(req.makerId(), req.meetingId(),
                        req.dateOccurred(), req.startTime(), req.endTime(),
                        req.theme(), req.location(), req.description(),
                        req.disciplesState(), req.investment(), req.presentDiscipleIds()))
                .map(RecordResponse::from);
    }

    @GetMapping("/makers/{makerId}/records")
    @PreAuthorize("hasAuthority('bbcms:discipleship:read')")
    public Flux<RecordResponse> records(@PathVariable UUID makerId) {
        return useCase.listByMaker(makerId).map(RecordResponse::from);
    }

    public record AssignRequest(@NotNull UUID makerId, @NotNull UUID discipleId) {}
    public record EndLinkRequest(LocalDate when) {}
    public record RecordRequest(@NotNull UUID makerId, UUID meetingId, @NotNull LocalDate dateOccurred,
                                LocalTime startTime, LocalTime endTime, String theme, String location,
                                String description, String disciplesState, String investment,
                                Set<UUID> presentDiscipleIds) {}
    public record DiscipleLinkResponse(UUID id, UUID makerId, UUID discipleId,
                                       LocalDate dateAssigned, LocalDate dateEnded, boolean active) {
        static DiscipleLinkResponse from(DiscipleLink l) {
            return new DiscipleLinkResponse(l.getId(), l.getDiscipleMakerMemberId(),
                    l.getDiscipleMemberId(), l.getDateAssigned(), l.getDateEnded(), l.isActive());
        }
    }
    public record RecordResponse(UUID id, UUID makerId, UUID meetingId, LocalDate dateOccurred,
                                 String theme, Set<UUID> presentDiscipleIds) {
        static RecordResponse from(DiscipleshipRecord r) {
            return new RecordResponse(r.getId(), r.getDiscipleMakerMemberId(),
                    r.getMeetingId().orElse(null), r.getDateOccurred(), r.getTheme(),
                    r.getPresentDiscipleIds());
        }
    }
}
