package com.chf.bbcms.people.application.port.out;

import com.chf.bbcms.people.domain.MentorAssignment;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface MentorAssignmentRepository {
    Flux<MentorAssignment> findByMember(UUID memberId);
    Flux<MentorAssignment> findByBibleClub(UUID bibleClubId);
    Mono<MentorAssignment> save(MentorAssignment assignment);
    Mono<Void> delete(UUID memberId, UUID bibleClubId);
}
