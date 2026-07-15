package com.chf.bbcms.identity.application.service;

import com.chf.bbcms.identity.application.port.in.ManageMembershipUseCase;
import com.chf.bbcms.identity.application.port.out.MembershipRequestRepository;
import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.MembershipRequestStatus;
import com.chf.bbcms.identity.domain.UserType;
import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.domain.ProfessionalPosition;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Orchestre l'approbation d'une demande d'adhésion: crée un Member dans le contexte
 * "people" + promeut le UserAccount au type approprié, dans une seule transaction R2DBC.
 */
@Service
public class MembershipService implements ManageMembershipUseCase {

    // UUID stables définis dans 17-seed-roles.xml
    private static final UUID ROLE_STUDENT          = UUID.fromString("11111111-0000-0000-0000-00000000000B");
    private static final UUID ROLE_PROFESSIONAL     = UUID.fromString("11111111-0000-0000-0000-00000000000C");
    private static final UUID ROLE_NATIONAL_LEADER  = UUID.fromString("11111111-0000-0000-0000-000000000002");
    private static final UUID SYSTEM_USER           = UUID.fromString("00000000-0000-0000-0000-000000000000");

    private final MembershipRequestRepository requestRepository;
    private final UserAccountRepository userRepository;
    private final ManageMemberUseCase memberUseCase;
    private final TransactionalOperator txOperator;
    private final DatabaseClient dbClient;

    public MembershipService(MembershipRequestRepository requestRepository,
                             UserAccountRepository userRepository,
                             ManageMemberUseCase memberUseCase,
                             TransactionalOperator txOperator,
                             DatabaseClient dbClient) {
        this.requestRepository = requestRepository;
        this.userRepository = userRepository;
        this.memberUseCase = memberUseCase;
        this.txOperator = txOperator;
        this.dbClient = dbClient;
    }

    @Override
    public Mono<MembershipRequest> approve(UUID requestId, UUID approverId,
                                           UUID assignedBibleClubId, UUID assignedLevelId, String comment) {
        return findById(requestId)
                .flatMap(req -> {
                    req.approve(approverId, assignedBibleClubId, assignedLevelId, comment);
                    return userRepository.findById(req.getUserAccountId())
                            .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", req.getUserAccountId())))
                            .flatMap(account -> {
                                // Activer le compte si encore en PENDING (cas d'activation manuelle par leader)
                                if (account.getStatus().name().equals("PENDING")) {
                                    account.activate();
                                }
                                account.promoteTo(req.getRequestedType());
                                return userRepository.save(account)
                                        .then(createMember(req))
                                        .then(assignDefaultRole(req.getUserAccountId(), req.getRequestedType()))
                                        .then(requestRepository.save(req));
                            });
                })
                .as(txOperator::transactional);
    }

    private Mono<?> createMember(MembershipRequest req) {
        return switch (req.getRequestedType()) {
            case STUDENT -> memberUseCase.createStudent(req.getUserAccountId(),
                    req.getBibleClubId().orElseThrow(),
                    req.getLevelId().orElseThrow());
            case PROFESSIONAL -> memberUseCase.createProfessional(req.getUserAccountId(),
                    req.getProfession(), ProfessionalPosition.SIMPLE_PROFESSIONAL);
            case NATIONAL_LEADER -> memberUseCase.createNationalLeader(req.getUserAccountId(), req.getProfession());
            case VISITOR -> Mono.empty();
        };
    }

    /**
     * Assigne le rôle par défaut correspondant au type de membre approuvé,
     * sauf si un rôle identique est déjà actif (idempotent).
     */
    private Mono<Void> assignDefaultRole(UUID userAccountId, UserType type) {
        UUID roleId = switch (type) {
            case STUDENT         -> ROLE_STUDENT;
            case PROFESSIONAL    -> ROLE_PROFESSIONAL;
            case NATIONAL_LEADER -> ROLE_NATIONAL_LEADER;
            case VISITOR         -> null;
        };
        if (roleId == null) return Mono.empty();

        final UUID finalRoleId = roleId;
        return dbClient.sql("""
                SELECT count(*) AS n FROM bbcms_user_role_assignment
                 WHERE user_account_id = :uid AND role_id = :rid AND active = true
                """)
                .bind("uid", userAccountId)
                .bind("rid", finalRoleId)
                .map((row, m) -> row.get("n", Long.class))
                .one()
                .flatMap(count -> {
                    if (count != null && count > 0) return Mono.empty();
                    return dbClient.sql("""
                            INSERT INTO bbcms_user_role_assignment
                                (user_account_id, role_id, scope_bible_club_id, active,
                                 created_by, created_at, updated_by, updated_at, version)
                            VALUES (:uid, :rid, NULL, true, :sys, :now, :sys, :now, 0)
                            """)
                            .bind("uid", userAccountId)
                            .bind("rid", finalRoleId)
                            .bind("sys", SYSTEM_USER)
                            .bind("now", Instant.now())
                            .then();
                });
    }

    @Override
    public Mono<MembershipRequest> reject(UUID requestId, UUID approverId, String comment) {
        return findById(requestId)
                .flatMap(req -> { req.reject(approverId, comment); return requestRepository.save(req); });
    }

    @Override
    public Mono<MembershipRequest> cancel(UUID requestId) {
        return findById(requestId).flatMap(req -> { req.cancel(); return requestRepository.save(req); });
    }

    @Override
    public Mono<MembershipRequest> findById(UUID requestId) {
        return requestRepository.findById(requestId)
                .switchIfEmpty(Mono.error(new NotFoundException("MembershipRequest", requestId)));
    }

    @Override
    public Flux<MembershipRequest> listByStatus(MembershipRequestStatus status) {
        return requestRepository.findByStatus(status);
    }
}
