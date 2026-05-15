package com.chf.bbcms.evangelism.adapter.in.web;

import com.chf.bbcms.evangelism.application.port.in.ManageEvangelismUseCase;
import com.chf.bbcms.evangelism.application.port.in.ManageEvangelismUseCase.RecordSessionCommand;
import com.chf.bbcms.evangelism.domain.EvangelismProgram;
import com.chf.bbcms.evangelism.domain.EvangelismProgramType;
import com.chf.bbcms.evangelism.domain.EvangelismRecord;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/evangelism")
public class EvangelismController {

    private final ManageEvangelismUseCase useCase;

    public EvangelismController(ManageEvangelismUseCase useCase) { this.useCase = useCase; }

    @PostMapping("/programs")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:evangelism:program-create')")
    public Mono<ProgramResponse> draftProgram(@Valid @RequestBody DraftProgramRequest req) {
        return useCase.draftProgram(req.title(), req.type(), req.objective()).map(ProgramResponse::from);
    }

    @PostMapping("/programs/{id}/dates")
    @PreAuthorize("hasAuthority('bbcms:evangelism:program-create')")
    public Mono<ProgramResponse> addDate(@PathVariable UUID id, @RequestBody DateRequest req) {
        return useCase.addProgramDate(id, req.date()).map(ProgramResponse::from);
    }

    @PostMapping("/programs/{id}/bible-clubs")
    @PreAuthorize("hasAuthority('bbcms:evangelism:program-create')")
    public Mono<ProgramResponse> addBbc(@PathVariable UUID id, @RequestBody BbcRequest req) {
        return useCase.addProgramBibleClub(id, req.bibleClubId()).map(ProgramResponse::from);
    }

    @PostMapping("/programs/{id}/activate")
    @PreAuthorize("hasAuthority('bbcms:evangelism:program-create')")
    public Mono<ProgramResponse> activate(@PathVariable UUID id) {
        return useCase.activateProgram(id).map(ProgramResponse::from);
    }

    @PostMapping("/programs/{id}/close")
    @PreAuthorize("hasAuthority('bbcms:evangelism:program-create')")
    public Mono<ProgramResponse> close(@PathVariable UUID id) {
        return useCase.closeProgram(id).map(ProgramResponse::from);
    }

    @GetMapping("/programs")
    @PreAuthorize("hasAuthority('bbcms:evangelism:read')")
    public Flux<ProgramResponse> listPrograms() {
        return useCase.listPrograms().map(ProgramResponse::from);
    }

    @GetMapping("/programs/{id}")
    @PreAuthorize("hasAuthority('bbcms:evangelism:read')")
    public Mono<ProgramResponse> getProgram(@PathVariable UUID id) {
        return useCase.findProgramById(id).map(ProgramResponse::from);
    }

    @PostMapping("/programs/{id}/records")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:evangelism:record-create')")
    public Mono<RecordResponse> record(@PathVariable("id") UUID programId,
                                       @Valid @RequestBody CreateRecordRequest req) {
        return useCase.recordSession(new RecordSessionCommand(
                        programId, req.date(), req.preached(), req.believed(), req.encouraged(),
                        req.tracts(), req.savedContacts(), req.notes(), req.participantMemberIds()))
                .map(RecordResponse::from);
    }

    @GetMapping("/programs/{id}/records")
    @PreAuthorize("hasAuthority('bbcms:evangelism:read')")
    public Flux<RecordResponse> listRecords(@PathVariable("id") UUID programId) {
        return useCase.listRecordsByProgram(programId).map(RecordResponse::from);
    }

    public record DraftProgramRequest(@NotBlank String title, @NotNull EvangelismProgramType type,
                                      @Min(0) int objective) {}
    public record DateRequest(@NotNull LocalDate date) {}
    public record BbcRequest(@NotNull UUID bibleClubId) {}
    public record CreateRecordRequest(@NotNull LocalDate date,
                                      @Min(0) int preached, @Min(0) int believed, @Min(0) int encouraged,
                                      @Min(0) int tracts, String savedContacts, String notes,
                                      Set<UUID> participantMemberIds) {}

    public record ProgramResponse(UUID id, String title, String type, String status,
                                  int objectiveBelievers, int totalSaved, double percentageReached,
                                  Set<LocalDate> dates, Set<UUID> bibleClubIds) {
        static ProgramResponse from(EvangelismProgram p) {
            return new ProgramResponse(p.getId(), p.getTitle(), p.getType().name(), p.getStatus().name(),
                    p.getObjectiveBelievers(), p.getTotalSaved(), p.percentageReached(),
                    p.getDates(), p.getBibleClubIds());
        }
    }

    public record RecordResponse(UUID id, UUID programId, LocalDate date,
                                 int preached, int believed, int encouraged, int tracts,
                                 Set<UUID> participantMemberIds) {
        static RecordResponse from(EvangelismRecord r) {
            return new RecordResponse(r.getId(), r.getProgramId(), r.getRecordDate(),
                    r.getNbPreached(), r.getNbBelieved(), r.getNbEncouraged(), r.getNbTractsShared(),
                    r.getParticipantMemberIds());
        }
    }
}
