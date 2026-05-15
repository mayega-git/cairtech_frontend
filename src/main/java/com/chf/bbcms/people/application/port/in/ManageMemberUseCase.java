package com.chf.bbcms.people.application.port.in;

import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.ProfessionalPosition;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ManageMemberUseCase {

    Mono<Member> createStudent(UUID userAccountId, UUID bibleClubId, UUID levelId);
    Mono<Member> createProfessional(UUID userAccountId, String profession, ProfessionalPosition position);
    Mono<Member> createNationalLeader(UUID userAccountId, String profession);

    Mono<Member> findById(UUID memberId);
    Mono<Member> findByUserAccount(UUID userAccountId);
    Flux<Member> listByBibleClub(UUID bibleClubId);

    Mono<Member> transferLevel(UUID memberId, UUID newLevelId);
    Mono<Member> transferBibleClub(UUID memberId, UUID newBibleClubId, UUID newLevelId);
    Mono<Member> addDepartment(UUID memberId, Department department);
    Mono<Member> removeDepartment(UUID memberId, Department department);
    Mono<Member> leave(UUID memberId);
}
