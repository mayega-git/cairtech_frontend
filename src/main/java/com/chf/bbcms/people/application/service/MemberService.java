package com.chf.bbcms.people.application.service;

import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.ProfessionalPosition;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class MemberService implements ManageMemberUseCase {

    private final MemberRepository repository;

    public MemberService(MemberRepository repository) {
        this.repository = repository;
    }

    @Override
    public Mono<Member> createStudent(UUID userAccountId, UUID bibleClubId, UUID levelId) {
        return repository.save(Member.newStudent(userAccountId, bibleClubId, levelId));
    }

    @Override
    public Mono<Member> createProfessional(UUID userAccountId, String profession,
                                           ProfessionalPosition position) {
        return repository.save(Member.newProfessional(userAccountId, profession, position));
    }

    @Override
    public Mono<Member> createNationalLeader(UUID userAccountId, String profession) {
        return repository.save(Member.newNationalLeader(userAccountId, profession));
    }

    @Override
    public Mono<Member> findById(UUID memberId) {
        return repository.findById(memberId)
                .switchIfEmpty(Mono.error(new NotFoundException("Member", memberId)));
    }

    @Override
    public Mono<Member> findByUserAccount(UUID userAccountId) {
        return repository.findByUserAccountId(userAccountId);
    }

    @Override
    public Flux<Member> listByBibleClub(UUID bibleClubId) {
        return repository.findByBibleClub(bibleClubId);
    }

    @Override
    public Mono<Member> transferLevel(UUID memberId, UUID newLevelId) {
        return findById(memberId).flatMap(m -> { m.transferLevel(newLevelId); return repository.save(m); });
    }

    @Override
    public Mono<Member> transferBibleClub(UUID memberId, UUID newBibleClubId, UUID newLevelId) {
        return findById(memberId).flatMap(m -> {
            m.transferBibleClub(newBibleClubId, newLevelId);
            return repository.save(m);
        });
    }

    @Override
    public Mono<Member> addDepartment(UUID memberId, Department department) {
        return findById(memberId).flatMap(m -> { m.addDepartment(department); return repository.save(m); });
    }

    @Override
    public Mono<Member> removeDepartment(UUID memberId, Department department) {
        return findById(memberId).flatMap(m -> { m.removeDepartment(department); return repository.save(m); });
    }

    @Override
    public Mono<Member> leave(UUID memberId) {
        return findById(memberId).flatMap(m -> { m.leave(); return repository.save(m); });
    }
}
