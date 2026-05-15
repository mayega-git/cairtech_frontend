package com.chf.bbcms.event.application.service;

import com.chf.bbcms.event.application.port.in.ManageEventUseCase;
import com.chf.bbcms.event.application.port.out.EventRepository;
import com.chf.bbcms.event.domain.Event;
import com.chf.bbcms.event.domain.EventAttended;
import com.chf.bbcms.event.domain.EventParticipation;
import com.chf.bbcms.event.domain.EventType;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import com.chf.bbcms.shared.domain.NotFoundException;
import com.chf.bbcms.shared.outbox.DomainEventBus;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Service
public class EventService implements ManageEventUseCase {

    private final EventRepository repository;
    private final DomainEventBus eventBus;

    public EventService(EventRepository repository, DomainEventBus eventBus) {
        this.repository = repository;
        this.eventBus = eventBus;
    }

    @Override
    public Mono<Event> plan(String title, EventType type, Instant plannedStart, Instant plannedEnd,
                            String location, Integer maxPictures) {
        return repository.save(Event.plan(title, type, plannedStart, plannedEnd, location,
                maxPictures == null ? 50 : maxPictures));
    }

    @Override
    public Mono<Event> openRegistration(UUID eventId) {
        return load(eventId).flatMap(e -> { e.openRegistration(); return repository.save(e); });
    }

    @Override
    public Mono<Event> start(UUID eventId, Instant when) {
        return load(eventId).flatMap(e -> { e.start(when); return repository.save(e); });
    }

    @Override
    public Mono<Event> end(UUID eventId, Instant when) {
        return load(eventId).flatMap(e -> { e.end(when); return repository.save(e); });
    }

    @Override
    public Mono<Event> cancel(UUID eventId) {
        return load(eventId).flatMap(e -> { e.cancel(); return repository.save(e); });
    }

    @Override
    public Mono<Event> findById(UUID eventId) { return load(eventId); }

    @Override
    public Flux<Event> listAll() { return repository.findAll(); }

    @Override
    public Mono<EventParticipation> enrollMember(UUID eventId, UUID memberId) {
        return load(eventId).flatMap(e -> {
            if (!e.acceptsEnrollment())
                return Mono.error(new BusinessRuleViolation("BBCMS_EVENT_BAD_STATE",
                        "Event is not accepting enrollment (status=" + e.getStatus() + ")"));
            return repository.saveParticipation(EventParticipation.enrollMember(eventId, memberId));
        });
    }

    @Override
    public Mono<EventParticipation> markPresent(UUID eventId, UUID memberId, Instant when) {
        return repository.findParticipation(eventId, memberId)
                .switchIfEmpty(Mono.error(new NotFoundException("EventParticipation",
                        eventId + "/" + memberId)))
                .flatMap(p -> {
                    p.markPresent(when);
                    return repository.saveParticipation(p)
                            .flatMap(saved -> eventBus.publish(new EventAttended(eventId, memberId, Instant.now()))
                                    .thenReturn(saved));
                });
    }

    @Override
    public Flux<EventParticipation> listParticipations(UUID eventId) {
        return repository.findParticipations(eventId);
    }

    private Mono<Event> load(UUID id) {
        return repository.findById(id).switchIfEmpty(Mono.error(new NotFoundException("Event", id)));
    }
}
