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
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Orchestre l'approbation d'une demande d'adhésion: crée un Member dans le contexte
 * "people" + promeut le UserAccount au type approprié, dans une seule transaction R2DBC.
 */
@Service
public class MembershipService implements ManageMembershipUseCase {

    private final MembershipRequestRepository requestRepository;
    private final UserAccountRepository userRepository;
    private final ManageMemberUseCase memberUseCase;
    private final TransactionalOperator txOperator;

    public MembershipService(MembershipRequestRepository requestRepository,
                             UserAccountRepository userRepository,
                             ManageMemberUseCase memberUseCase,
                             TransactionalOperator txOperator) {
        this.requestRepository = requestRepository;
        this.userRepository = userRepository;
        this.memberUseCase = memberUseCase;
        this.txOperator = txOperator;
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
