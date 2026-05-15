package com.chf.bbcms.event.application.port.in;

import com.chf.bbcms.event.domain.Event;
import com.chf.bbcms.event.domain.EventParticipation;
import com.chf.bbcms.event.domain.EventType;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

public interface ManageEventUseCase {
    Mono<Event> plan(String title, EventType type, Instant plannedStart, Instant plannedEnd,
                     String location, Integer maxPictures, UUID imageFileId);
    Mono<Event> openRegistration(UUID eventId);
    Mono<Event> setImage(UUID eventId, UUID imageFileId);
    Mono<Event> start(UUID eventId, Instant when);
    Mono<Event> end(UUID eventId, Instant when);
    Mono<Event> cancel(UUID eventId);
    Mono<Event> findById(UUID eventId);
    Flux<Event> listAll();

    Mono<EventParticipation> enrollMember(UUID eventId, UUID memberId);
    Mono<EventParticipation> markPresent(UUID eventId, UUID memberId, Instant when);
    Flux<EventParticipation> listParticipations(UUID eventId);
}
