package com.chf.bbcms.organization.application.port.out;

import com.chf.bbcms.organization.domain.LeadershipAssignment;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface LeadershipAssignmentRepository {
    Mono<LeadershipAssignment> findById(UUID id);
    Flux<LeadershipAssignment> findActiveByMember(UUID memberId);
    Flux<LeadershipAssignment> findActiveByBibleClub(UUID bibleClubId);
    Mono<LeadershipAssignment> save(LeadershipAssignment la);
}
