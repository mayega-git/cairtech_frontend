package com.chf.bbcms.shared.outbox;

import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;

import java.util.UUID;

public interface OutboxRepository extends ReactiveCrudRepository<OutboxEntry, UUID> {

    @Query("SELECT * FROM bbcms_domain_event WHERE processed = false ORDER BY created_at ASC LIMIT :limit")
    Flux<OutboxEntry> findUnprocessed(int limit);
}
