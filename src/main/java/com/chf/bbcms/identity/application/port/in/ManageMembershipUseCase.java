package com.chf.bbcms.identity.application.port.in;

import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ManageMembershipUseCase {

    Mono<MembershipRequest> approve(UUID requestId, UUID approverId,
                                    UUID assignedBibleClubId, UUID assignedLevelId, String comment);

    Mono<MembershipRequest> reject(UUID requestId, UUID approverId, String comment);

    Mono<MembershipRequest> cancel(UUID requestId);

    Mono<MembershipRequest> findById(UUID requestId);

    Flux<MembershipRequest> listByStatus(MembershipRequestStatus status);
}
