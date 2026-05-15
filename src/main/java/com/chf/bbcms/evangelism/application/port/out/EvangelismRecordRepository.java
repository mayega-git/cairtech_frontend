package com.chf.bbcms.evangelism.application.port.out;

import com.chf.bbcms.evangelism.domain.EvangelismRecord;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface EvangelismRecordRepository {
    Mono<EvangelismRecord> findById(UUID id);
    Flux<EvangelismRecord> findByProgram(UUID programId);
    Mono<EvangelismRecord> save(EvangelismRecord record);
}
