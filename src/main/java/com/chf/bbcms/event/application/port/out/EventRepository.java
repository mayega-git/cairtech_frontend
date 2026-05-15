package com.chf.bbcms.event.application.port.out;

import com.chf.bbcms.event.domain.Event;
import com.chf.bbcms.event.domain.EventParticipation;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface EventRepository {
    Mono<Event> findById(UUID id);
    Flux<Event> findAll();
    Mono<Event> save(Event event);

    Flux<EventParticipation> findParticipations(UUID eventId);
    Mono<EventParticipation> findParticipation(UUID eventId, UUID memberId);
    Mono<EventParticipation> saveParticipation(EventParticipation participation);

    /** Compte les présences validées d'un membre dans l'année académique. */
    Mono<Long> countAttendedByMember(UUID memberId, int academicYear);
}
