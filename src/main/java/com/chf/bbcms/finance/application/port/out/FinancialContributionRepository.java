package com.chf.bbcms.finance.application.port.out;

import com.chf.bbcms.finance.domain.ContributionLine;
import com.chf.bbcms.finance.domain.FinancialContribution;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface FinancialContributionRepository {
    Mono<FinancialContribution> findById(UUID id);
    Flux<FinancialContribution> findByBibleClub(UUID bibleClubId);
    Mono<FinancialContribution> save(FinancialContribution contribution);

    Flux<ContributionLine> findLinesByContribution(UUID contributionId);
    Mono<ContributionLine> saveLine(ContributionLine line);
}
