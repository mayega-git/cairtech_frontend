package com.chf.bbcms.attendance.application.port.out;

import com.chf.bbcms.attendance.domain.InactivityWatch;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface InactivityWatchRepository {
    Mono<InactivityWatch> findByMember(UUID memberId);
    Flux<InactivityWatch> findActive();
    Mono<InactivityWatch> save(InactivityWatch watch);
}
