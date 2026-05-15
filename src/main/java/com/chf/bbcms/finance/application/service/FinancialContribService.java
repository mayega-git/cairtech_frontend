package com.chf.bbcms.finance.application.service;

import com.chf.bbcms.finance.application.port.in.ManageFinancialContribUseCase;
import com.chf.bbcms.finance.application.port.out.FinancialContributionRepository;
import com.chf.bbcms.finance.domain.ContributionLine;
import com.chf.bbcms.finance.domain.FinancialContribution;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Service
public class FinancialContribService implements ManageFinancialContribUseCase {

    private final FinancialContributionRepository repository;
    private final TransactionalOperator txOperator;

    public FinancialContribService(FinancialContributionRepository repository,
                                   TransactionalOperator txOperator) {
        this.repository = repository;
        this.txOperator = txOperator;
    }

    @Override
    public Mono<FinancialContribution> openContribution(UUID bibleClubId, String title, String description,
                                                        BigDecimal objective, LocalDate dateOpen) {
        return repository.save(FinancialContribution.open(bibleClubId, title, description, objective, dateOpen));
    }

    @Override
    public Mono<FinancialContribution> closeContribution(UUID id, LocalDate when) {
        return load(id).flatMap(c -> { c.close(when); return repository.save(c); });
    }

    @Override
    public Mono<FinancialContribution> findById(UUID id) { return load(id); }

    @Override
    public Flux<FinancialContribution> listByBibleClub(UUID bibleClubId) {
        return repository.findByBibleClub(bibleClubId);
    }

    @Override
    public Mono<ContributionLine> recordPayment(RecordPaymentCommand cmd) {
        return load(cmd.contributionId())
                .flatMap(c -> {
                    c.addAmount(cmd.amount());
                    ContributionLine line = ContributionLine.record(cmd.contributionId(),
                            cmd.memberId(), cmd.contributorName(), cmd.amount(),
                            cmd.channel(), cmd.reference(), cmd.paymentDate());
                    return repository.save(c).then(repository.saveLine(line));
                })
                .as(txOperator::transactional);
    }

    @Override
    public Flux<ContributionLine> listPayments(UUID contributionId) {
        return repository.findLinesByContribution(contributionId);
    }

    private Mono<FinancialContribution> load(UUID id) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("FinancialContribution", id)));
    }
}
