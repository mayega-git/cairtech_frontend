package com.chf.bbcms.finance.application.port.in;

import com.chf.bbcms.finance.domain.ContributionLine;
import com.chf.bbcms.finance.domain.FinancialContribution;
import com.chf.bbcms.finance.domain.PaymentChannel;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public interface ManageFinancialContribUseCase {

    Mono<FinancialContribution> openContribution(UUID bibleClubId, String title, String description,
                                                 BigDecimal objective, LocalDate dateOpen);
    Mono<FinancialContribution> closeContribution(UUID id, LocalDate when);
    Mono<FinancialContribution> findById(UUID id);
    Flux<FinancialContribution> listByBibleClub(UUID bibleClubId);

    Mono<ContributionLine> recordPayment(RecordPaymentCommand cmd);
    Flux<ContributionLine> listPayments(UUID contributionId);

    record RecordPaymentCommand(UUID contributionId, UUID memberId, String contributorName,
                                BigDecimal amount, PaymentChannel channel, String reference,
                                LocalDate paymentDate) {}
}
