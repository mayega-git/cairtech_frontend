package com.chf.bbcms.event.adapter.in.web;

import com.chf.bbcms.event.application.port.in.ManageEventUseCase;
import com.chf.bbcms.event.domain.Event;
import com.chf.bbcms.event.domain.EventParticipation;
import com.chf.bbcms.event.domain.EventType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/events")
public class EventController {

    private final ManageEventUseCase useCase;

    public EventController(ManageEventUseCase useCase) { this.useCase = useCase; }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:event:plan')")
    public Mono<EventResponse> plan(@Valid @RequestBody PlanRequest req) {
        return useCase.plan(req.title(), req.type(), req.plannedStart(), req.plannedEnd(),
                req.location(), req.maxPictures()).map(EventResponse::from);
    }

    @PostMapping("/{id}/open-registration")
    @PreAuthorize("hasAuthority('bbcms:event:plan')")
    public Mono<EventResponse> openRegistration(@PathVariable UUID id) {
        return useCase.openRegistration(id).map(EventResponse::from);
    }

    @PostMapping("/{id}/start")
    @PreAuthorize("hasAuthority('bbcms:event:plan')")
    public Mono<EventResponse> start(@PathVariable UUID id, @RequestBody StartRequest req) {
        return useCase.start(id, req.when()).map(EventResponse::from);
    }

    @PostMapping("/{id}/end")
    @PreAuthorize("hasAuthority('bbcms:event:plan')")
    public Mono<EventResponse> end(@PathVariable UUID id, @RequestBody StartRequest req) {
        return useCase.end(id, req.when()).map(EventResponse::from);
    }

    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasAuthority('bbcms:event:plan')")
    public Mono<EventResponse> cancel(@PathVariable UUID id) {
        return useCase.cancel(id).map(EventResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:event:read')")
    public Flux<EventResponse> list() { return useCase.listAll().map(EventResponse::from); }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:event:read')")
    public Mono<EventResponse> get(@PathVariable UUID id) { return useCase.findById(id).map(EventResponse::from); }

    @PostMapping("/{id}/enroll")
    @PreAuthorize("hasAuthority('bbcms:event:enroll')")
    public Mono<ParticipationResponse> enroll(@PathVariable UUID id, @Valid @RequestBody EnrollRequest req) {
        return useCase.enrollMember(id, req.memberId()).map(ParticipationResponse::from);
    }

    @PostMapping("/{id}/presence")
    @PreAuthorize("hasAuthority('bbcms:event:record-presence')")
    public Mono<ParticipationResponse> markPresent(@PathVariable UUID id, @Valid @RequestBody PresenceRequest req) {
        return useCase.markPresent(id, req.memberId(), req.when()).map(ParticipationResponse::from);
    }

    @GetMapping("/{id}/participations")
    @PreAuthorize("hasAuthority('bbcms:event:read')")
    public Flux<ParticipationResponse> participations(@PathVariable UUID id) {
        return useCase.listParticipations(id).map(ParticipationResponse::from);
    }

    public record PlanRequest(@NotBlank String title, @NotNull EventType type,
                              @NotNull Instant plannedStart, Instant plannedEnd,
                              String location, Integer maxPictures) {}
    public record StartRequest(Instant when) {}
    public record EnrollRequest(@NotNull UUID memberId) {}
    public record PresenceRequest(@NotNull UUID memberId, Instant when) {}

    public record EventResponse(UUID id, String title, String type, String status,
                                Instant plannedStart, Instant plannedEnd, Instant startedAt,
                                Instant endedAt, Integer durationMinutes, String location, int maxPictures) {
        static EventResponse from(Event e) {
            return new EventResponse(e.getId(), e.getTitle(), e.getType().name(), e.getStatus().name(),
                    e.getPlannedStartDt(), e.getPlannedEndDt(), e.getStartedAt(), e.getEndedAt(),
                    e.getDurationMinutes(), e.getLocation(), e.getMaxPictures());
        }
    }

    public record ParticipationResponse(UUID id, UUID eventId, UUID memberId, UUID visitorId,
                                        Instant registeredAt, boolean present, Instant presentAt) {
        static ParticipationResponse from(EventParticipation p) {
            return new ParticipationResponse(p.getId(), p.getEventId(),
                    p.getMemberId().orElse(null), p.getVisitorId().orElse(null),
                    p.getRegisteredAt(), p.isPresent(), p.getPresentAt());
        }
    }
}
