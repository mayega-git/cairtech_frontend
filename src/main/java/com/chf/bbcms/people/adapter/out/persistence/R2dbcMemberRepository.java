package com.chf.bbcms.people.adapter.out.persistence;

import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.MemberKind;
import com.chf.bbcms.people.domain.MemberStatus;
import com.chf.bbcms.people.domain.ProfessionalPosition;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Repository
public class R2dbcMemberRepository implements MemberRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcMemberRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<Member> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), MemberRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Mono<Member> findByUserAccountId(UUID userAccountId) {
        return template.selectOne(Query.query(Criteria.where("user_account_id").is(userAccountId)),
                        MemberRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<Member> findByBibleClub(UUID bibleClubId) {
        return template.select(MemberRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all()
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<Member> findActiveStudents() {
        return template.select(MemberRow.class)
                .matching(Query.query(Criteria.where("member_kind").is(MemberKind.STUDENT.name())
                        .and("status").is(MemberStatus.ACTIVE.name())))
                .all()
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<Member> findByStatus(MemberStatus status) {
        return template.select(MemberRow.class)
                .matching(Query.query(Criteria.where("status").is(status.name())))
                .all()
                .flatMap(this::toDomain);
    }

    @Override
    public Mono<Member> save(Member m) {
        MemberRow row = toRow(m);
        Mono<MemberRow> saved = (row.getId() == null ? template.insert(row) : template.update(row));
        return saved.flatMap(persisted -> persistDepartments(persisted.getId(), m.getDepartments())
                .thenReturn(persisted))
                .flatMap(this::toDomain);
    }

    private Mono<Void> persistDepartments(UUID memberId, Set<Department> departments) {
        Mono<Void> deleteExisting = client.sql("DELETE FROM bbcms_member_department WHERE member_id = :id")
                .bind("id", memberId).then();
        if (departments == null || departments.isEmpty()) return deleteExisting;
        return deleteExisting.thenMany(Flux.fromIterable(departments)
                .flatMap(d -> client.sql(
                                "INSERT INTO bbcms_member_department(member_id, department) VALUES (:id, :d)")
                        .bind("id", memberId).bind("d", d.name()).then()))
                .then();
    }

    private Mono<Member> toDomain(MemberRow r) {
        Mono<Set<Department>> deps = client.sql(
                        "SELECT department FROM bbcms_member_department WHERE member_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> Department.valueOf(row.get("department", String.class)))
                .all()
                .collect(java.util.stream.Collectors.toSet());

        return deps.map(d -> Member.rehydrate(r.getId(), r.getUserAccountId(),
                MemberKind.valueOf(r.getMemberKind()),
                r.getBibleClubId(), r.getLevelId(),
                r.getParticipationScore(), r.getFaithfulPercentage(),
                r.getProfession(),
                r.getProfessionalPosition() == null ? null : ProfessionalPosition.valueOf(r.getProfessionalPosition()),
                MemberStatus.valueOf(r.getStatus()),
                d, r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()));
    }

    private MemberRow toRow(Member m) {
        MemberRow r = new MemberRow();
        r.setId(m.getId());
        r.setUserAccountId(m.getUserAccountId());
        r.setMemberKind(m.getKind().name());
        r.setBibleClubId(m.getBibleClubId().orElse(null));
        r.setLevelId(m.getLevelId().orElse(null));
        r.setParticipationScore(m.getParticipationScore());
        r.setFaithfulPercentage(m.getFaithfulPercentage());
        r.setProfession(m.getProfession());
        r.setProfessionalPosition(m.getProfessionalPosition() == null ? null : m.getProfessionalPosition().name());
        r.setStatus(m.getStatus().name());
        Instant now = Instant.now();
        if (m.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(m.getCreatedBy() == null ? SYSTEM : m.getCreatedBy());
            r.setCreatedAt(m.getCreatedAt() == null ? now : m.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(m.getVersion());
        return r;
    }
}
