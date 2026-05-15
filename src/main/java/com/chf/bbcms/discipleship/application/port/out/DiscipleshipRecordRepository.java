package com.chf.bbcms.discipleship.application.port.out;

import com.chf.bbcms.discipleship.domain.DiscipleshipRecord;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface DiscipleshipRecordRepository {
    Mono<DiscipleshipRecord> findById(UUID id);
    Flux<DiscipleshipRecord> findByMaker(UUID makerId);
    Mono<DiscipleshipRecord> save(DiscipleshipRecord record);
}
