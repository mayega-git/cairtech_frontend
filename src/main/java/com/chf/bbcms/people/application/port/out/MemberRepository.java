package com.chf.bbcms.people.application.port.out;

import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.MemberStatus;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface MemberRepository {
    Mono<Member> findById(UUID id);
    Mono<Member> findByUserAccountId(UUID userAccountId);
    Flux<Member> findByBibleClub(UUID bibleClubId);
    Flux<Member> findActiveStudents();
    Flux<Member> findByStatus(MemberStatus status);
    Mono<Member> save(Member member);
}
