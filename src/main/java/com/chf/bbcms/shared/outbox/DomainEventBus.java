package com.chf.bbcms.shared.outbox;

import com.chf.bbcms.shared.domain.DomainEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

/**
 * Publication d'événements de domaine via outbox transactionnelle.
 * À appeler dans la même transaction que l'écriture de l'agrégat.
 * Le OutboxPublisher (scheduler) republiera vers Spring ApplicationEventPublisher.
 */
@Component
public class DomainEventBus {

    private final OutboxRepository outboxRepository;
    private final ObjectMapper objectMapper;

    public DomainEventBus(OutboxRepository outboxRepository, ObjectMapper objectMapper) {
        this.outboxRepository = outboxRepository;
        this.objectMapper = objectMapper;
    }

    public Mono<Void> publish(DomainEvent event) {
        return Mono.fromCallable(() -> serialize(event))
                .flatMap(json -> outboxRepository.save(
                        OutboxEntry.create(event.type(), event.aggregateId(), json)))
                .then();
    }

    private String serialize(DomainEvent event) {
        try {
            return objectMapper.writeValueAsString(event);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize domain event " + event.type(), e);
        }
    }
}
