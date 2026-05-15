package com.chf.bbcms.evangelism.application.port.out;

import com.chf.bbcms.evangelism.domain.EvangelismProgram;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface EvangelismProgramRepository {
    Mono<EvangelismProgram> findById(UUID id);
    Flux<EvangelismProgram> findAll();
    Mono<EvangelismProgram> save(EvangelismProgram program);
}
