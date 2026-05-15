package com.chf.bbcms.identity.application.port.out;

import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface MembershipRequestRepository {
    Mono<MembershipRequest> findById(UUID id);
    Flux<MembershipRequest> findByStatus(MembershipRequestStatus status);
    Mono<MembershipRequest> save(MembershipRequest request);
}
