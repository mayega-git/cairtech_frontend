package com.chf.bbcms.people.application.port.out;

import com.chf.bbcms.people.domain.Visitor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface VisitorRepository {
    Mono<Visitor> findById(UUID id);
    Flux<Visitor> findByMeeting(UUID meetingId);
    Flux<Visitor> findByEvent(UUID eventId);
    Mono<Visitor> save(Visitor visitor);
}
