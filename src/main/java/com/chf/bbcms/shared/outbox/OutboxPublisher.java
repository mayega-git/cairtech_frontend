package com.chf.bbcms.shared.outbox;

import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scrute la table d'outbox bbcms_domain_event et republie chaque entrée
 * vers Spring ApplicationEventPublisher pour les listeners locaux.
 * Verrou ShedLock pour garantir un seul publisher actif par cluster.
 */
@Component
public class OutboxPublisher {

    private static final Logger log = LoggerFactory.getLogger(OutboxPublisher.class);

    private final OutboxRepository outboxRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final int batchSize;

    public OutboxPublisher(OutboxRepository outboxRepository,
                           ApplicationEventPublisher eventPublisher,
                           @Value("${bbcms.outbox.batch-size:100}") int batchSize) {
        this.outboxRepository = outboxRepository;
        this.eventPublisher = eventPublisher;
        this.batchSize = batchSize;
    }

    @Scheduled(fixedDelayString = "${bbcms.outbox.publish-interval:PT5S}")
    @SchedulerLock(name = "outbox-publisher", lockAtMostFor = "PT1M", lockAtLeastFor = "PT1S")
    public void publishPending() {
        outboxRepository.findUnprocessed(batchSize)
                .flatMap(entry -> {
                    try {
                        eventPublisher.publishEvent(new OutboxRepublished(entry.getType(),
                                entry.getAggregateId(), entry.getPayloadJson()));
                        entry.markProcessed();
                    } catch (Exception ex) {
                        log.warn("Failed to republish outbox entry {} ({}): {}",
                                entry.getId(), entry.getType(), ex.getMessage());
                        entry.markFailed(ex.getMessage());
                    }
                    return outboxRepository.save(entry);
                })
                .doOnError(err -> log.error("Outbox publisher tick failed", err))
                .subscribe();
    }
}
