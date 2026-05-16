package com.chf.bbcms.people.application.service;

import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.application.port.in.MemberWithProfile;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.ProfessionalPosition;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Service
public class MemberService implements ManageMemberUseCase {

    private final MemberRepository repository;
    private final DatabaseClient client;

    public MemberService(MemberRepository repository, DatabaseClient client) {
        this.repository = repository;
        this.client = client;
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

    private static final String MEMBER_WITH_PROFILE_COLUMNS =
            "m.id AS member_id, m.user_account_id, m.member_kind, m.bible_club_id, m.level_id, " +
            "m.participation_score, m.faithful_percentage, m.profession, m.professional_position, " +
            "m.status AS member_status, " +
            "u.email, u.first_names, u.next_names, u.gender, u.date_of_birth, u.picture_file_id, " +
            "u.status AS account_status, u.user_type";

    @Override
    public Mono<MemberWithProfile> findByIdWithProfile(UUID memberId) {
        return client.sql("""
                SELECT %s FROM bbcms_member m
                  JOIN bbcms_user_account u ON u.id = m.user_account_id
                 WHERE m.id = :id
                """.formatted(MEMBER_WITH_PROFILE_COLUMNS))
                .bind("id", memberId)
                .map((row, meta) -> mapWithProfile(row))
                .one()
                .flatMap(mwp -> hydrateDepartments(mwp));
    }

    @Override
    public Flux<MemberWithProfile> listByBibleClubWithProfile(UUID bibleClubId) {
        return client.sql("""
                SELECT %s FROM bbcms_member m
                  JOIN bbcms_user_account u ON u.id = m.user_account_id
                 WHERE m.bible_club_id = :bbc
                 ORDER BY u.first_names ASC, u.next_names ASC
                """.formatted(MEMBER_WITH_PROFILE_COLUMNS))
                .bind("bbc", bibleClubId)
                .map((row, meta) -> mapWithProfile(row))
                .all()
                .flatMap(this::hydrateDepartments);
    }

    private MemberWithProfile mapWithProfile(io.r2dbc.spi.Row row) {
        return new MemberWithProfile(
                row.get("member_id", UUID.class),
                row.get("user_account_id", UUID.class),
                row.get("member_kind", String.class),
                row.get("bible_club_id", UUID.class),
                row.get("level_id", UUID.class),
                row.get("participation_score", Integer.class) == null ? 0
                        : row.get("participation_score", Integer.class),
                row.get("faithful_percentage", BigDecimal.class) == null
                        ? BigDecimal.ZERO
                        : row.get("faithful_percentage", BigDecimal.class),
                row.get("profession", String.class),
                row.get("professional_position", String.class),
                row.get("member_status", String.class),
                java.util.Set.of(),
                row.get("email", String.class),
                row.get("first_names", String.class),
                row.get("next_names", String.class),
                row.get("gender", String.class),
                row.get("date_of_birth", LocalDate.class),
                row.get("picture_file_id", UUID.class),
                row.get("account_status", String.class),
                row.get("user_type", String.class));
    }

    private Mono<MemberWithProfile> hydrateDepartments(MemberWithProfile mwp) {
        return client.sql("SELECT department FROM bbcms_member_department WHERE member_id = :id")
                .bind("id", mwp.memberId())
                .map((row, meta) -> row.get("department", String.class))
                .all()
                .collect(java.util.stream.Collectors.toSet())
                .map(deptCodes -> {
                    Set<Department> deps = new HashSet<>();
                    for (String c : deptCodes) {
                        try { deps.add(Department.valueOf(c)); } catch (Exception ignored) {}
                    }
                    return new MemberWithProfile(
                            mwp.memberId(), mwp.userAccountId(), mwp.kind(),
                            mwp.bibleClubId(), mwp.levelId(),
                            mwp.participationScore(), mwp.faithfulPercentage(),
                            mwp.profession(), mwp.professionalPosition(),
                            mwp.memberStatus(), deps,
                            mwp.email(), mwp.firstNames(), mwp.nextNames(),
                            mwp.gender(), mwp.dateOfBirth(), mwp.pictureFileId(),
                            mwp.accountStatus(), mwp.userType());
                });
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
