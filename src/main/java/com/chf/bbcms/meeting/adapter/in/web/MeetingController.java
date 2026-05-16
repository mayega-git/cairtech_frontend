package com.chf.bbcms.meeting.adapter.in.web;

import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase;
import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase.PictureItem;
import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase.PlanMeetingCommand;
import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase.PresenceItem;
import com.chf.bbcms.meeting.application.port.in.ManageMeetingUseCase.RecordMeetingCommand;
import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingType;
import com.chf.bbcms.meeting.domain.PresenceRole;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/meetings")
public class MeetingController {

    private final ManageMeetingUseCase useCase;

    public MeetingController(ManageMeetingUseCase useCase) { this.useCase = useCase; }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:meeting:plan')")
    public Mono<MeetingResponse> plan(@Valid @RequestBody PlanRequest req) {
        return useCase.plan(new PlanMeetingCommand(req.title(), req.type(),
                        req.bibleClubId(), req.levelId(), req.plannedDate(),
                        req.plannedStartTime(), req.plannedEndTime(),
                        req.teacherMemberId(), req.maxPictures()))
                .map(MeetingResponse::from);
    }

    @PostMapping("/{id}/start")
    @PreAuthorize("hasAuthority('bbcms:meeting:start')")
    public Mono<MeetingResponse> start(@PathVariable UUID id, @RequestBody StartRequest req) {
        return useCase.start(id, req.dateOccurred(), req.startTime()).map(MeetingResponse::from);
    }

    @PostMapping("/{id}/end")
    @PreAuthorize("hasAuthority('bbcms:meeting:end')")
    public Mono<MeetingResponse> end(@PathVariable UUID id, @RequestBody EndRequest req) {
        return useCase.end(id, req.endTime()).map(MeetingResponse::from);
    }

    @PostMapping("/{id}/record")
    @PreAuthorize("hasAuthority('bbcms:meeting:record')")
    public Mono<MeetingResponse> record(@PathVariable UUID id, @Valid @RequestBody RecordRequest req) {
        return useCase.record(new RecordMeetingCommand(id, req.dateOccurred(), req.startTime(), req.endTime(),
                        req.nbBelievers(), req.summary(), req.presents(), req.pictures()))
                .map(MeetingResponse::from);
    }

    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasAuthority('bbcms:meeting:cancel')")
    public Mono<MeetingResponse> cancel(@PathVariable UUID id) {
        return useCase.cancel(id).map(MeetingResponse::from);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:meeting:read')")
    public Mono<MeetingResponse> get(@PathVariable UUID id) {
        return useCase.findById(id).map(MeetingResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:meeting:read')")
    public reactor.core.publisher.Flux<MeetingResponse> list(@RequestParam("bibleClubId") UUID bibleClubId) {
        return useCase.listByBibleClub(bibleClubId).map(MeetingResponse::from);
    }

    @GetMapping("/{id}/presences")
    @PreAuthorize("hasAuthority('bbcms:meeting:read')")
    public reactor.core.publisher.Flux<PresenceResponse> presences(@PathVariable UUID id) {
        return useCase.listPresences(id).map(PresenceResponse::from);
    }

    @GetMapping("/{id}/pictures")
    @PreAuthorize("hasAuthority('bbcms:meeting:read')")
    public reactor.core.publisher.Flux<PictureResponse> pictures(@PathVariable UUID id) {
        return useCase.listPictures(id).map(PictureResponse::from);
    }

    public record PresenceResponse(UUID id, UUID memberId, UUID visitorId,
                                    java.time.Instant presentAt, String role) {
        static PresenceResponse from(com.chf.bbcms.meeting.domain.MeetingPresence p) {
            return new PresenceResponse(p.getId(),
                    p.getMemberId().orElse(null),
                    p.getVisitorId().orElse(null),
                    p.getPresentAt(),
                    p.getRole().name());
        }
    }

    public record PictureResponse(UUID id, UUID fileId, String caption, java.time.Instant takenAt) {
        static PictureResponse from(com.chf.bbcms.meeting.domain.MeetingPicture p) {
            return new PictureResponse(p.id(), p.fileId(), p.caption(), p.takenAt());
        }
    }

    public record PlanRequest(
            @NotBlank String title, @NotNull MeetingType type,
            UUID bibleClubId, UUID levelId,
            @NotNull LocalDate plannedDate, @NotNull LocalTime plannedStartTime,
            LocalTime plannedEndTime, UUID teacherMemberId, Integer maxPictures
    ) {}

    public record StartRequest(LocalDate dateOccurred, LocalTime startTime) {}
    public record EndRequest(LocalTime endTime) {}

    public record RecordRequest(
            LocalDate dateOccurred, LocalTime startTime, LocalTime endTime,
            @Min(0) int nbBelievers, String summary,
            List<PresenceItem> presents, List<PictureItem> pictures
    ) {}

    public record MeetingResponse(UUID id, String title, String type, String status,
                                  UUID bibleClubId, UUID levelId, LocalDate plannedDate,
                                  LocalTime plannedStartTime, LocalDate dateOccurred,
                                  Integer durationMinutes, int nbBelievers, int maxPictures,
                                  String summary, UUID teacherMemberId) {
        static MeetingResponse from(Meeting m) {
            return new MeetingResponse(m.getId(), m.getTitle(), m.getType().name(), m.getStatus().name(),
                    m.getBibleClubId().orElse(null), m.getLevelId().orElse(null),
                    m.getPlannedDate(), m.getPlannedStartTime(), m.getDateOccurred(),
                    m.getDurationMinutes(), m.getNbBelievers(), m.getMaxPictures(),
                    m.getSummary(), m.getTeacherMemberId().orElse(null));
        }
    }
}
