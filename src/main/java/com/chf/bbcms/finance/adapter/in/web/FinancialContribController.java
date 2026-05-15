package com.chf.bbcms.finance.adapter.in.web;

import com.chf.bbcms.finance.application.port.in.ManageFinancialContribUseCase;
import com.chf.bbcms.finance.application.port.in.ManageFinancialContribUseCase.RecordPaymentCommand;
import com.chf.bbcms.finance.domain.ContributionLine;
import com.chf.bbcms.finance.domain.FinancialContribution;
import com.chf.bbcms.finance.domain.PaymentChannel;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/finance/contributions")
public class FinancialContribController {

    private final ManageFinancialContribUseCase useCase;

    public FinancialContribController(ManageFinancialContribUseCase useCase) { this.useCase = useCase; }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-create')")
    public Mono<ContribResponse> open(@Valid @RequestBody OpenRequest req) {
        return useCase.openContribution(req.bibleClubId(), req.title(), req.description(),
                req.objective(), req.dateOpen()).map(ContribResponse::from);
    }

    @PostMapping("/{id}/close")
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-create')")
    public Mono<ContribResponse> close(@PathVariable UUID id, @RequestBody CloseRequest req) {
        return useCase.closeContribution(id, req.when()).map(ContribResponse::from);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-read')")
    public Mono<ContribResponse> get(@PathVariable UUID id) {
        return useCase.findById(id).map(ContribResponse::from);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-read')")
    public Flux<ContribResponse> list(@RequestParam UUID bibleClubId) {
        return useCase.listByBibleClub(bibleClubId).map(ContribResponse::from);
    }

    @PostMapping("/{id}/payments")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-record')")
    public Mono<LineResponse> recordPayment(@PathVariable("id") UUID contributionId,
                                            @Valid @RequestBody PaymentRequest req) {
        return useCase.recordPayment(new RecordPaymentCommand(contributionId, req.memberId(),
                        req.contributorName(), req.amount(), req.channel(), req.reference(),
                        req.paymentDate()))
                .map(LineResponse::from);
    }

    @GetMapping("/{id}/payments")
    @PreAuthorize("hasAuthority('bbcms:financial:contribution-read')")
    public Flux<LineResponse> listPayments(@PathVariable("id") UUID contributionId) {
        return useCase.listPayments(contributionId).map(LineResponse::from);
    }

    public record OpenRequest(@NotNull UUID bibleClubId, @NotBlank String title, String description,
                              @NotNull @DecimalMin("0.0") BigDecimal objective, LocalDate dateOpen) {}
    public record CloseRequest(LocalDate when) {}
    public record PaymentRequest(UUID memberId, String contributorName,
                                 @NotNull @DecimalMin(value = "0.0", inclusive = false) BigDecimal amount,
                                 @NotNull PaymentChannel channel, String reference, LocalDate paymentDate) {}

    public record ContribResponse(UUID id, UUID bibleClubId, String title, BigDecimal objectiveAmount,
                                  String currency, BigDecimal totalContributed, double percentageReached,
                                  String status, LocalDate dateOpen, LocalDate dateClose) {
        static ContribResponse from(FinancialContribution c) {
            return new ContribResponse(c.getId(), c.getBibleClubId(), c.getTitle(),
                    c.getObjectiveAmount(), c.getCurrency(), c.getTotalContributed(),
                    c.percentageReached(), c.getStatus().name(), c.getDateOpen(), c.getDateClose());
        }
    }

    public record LineResponse(UUID id, UUID contributionId, UUID contributorMemberId, String contributorName,
                               BigDecimal amount, String paymentChannel, String paymentReference,
                               LocalDate paymentDate) {
        static LineResponse from(ContributionLine l) {
            return new LineResponse(l.getId(), l.getContributionId(),
                    l.getContributorMemberId().orElse(null), l.getContributorName(),
                    l.getAmount(), l.getPaymentChannel().name(),
                    l.getPaymentReference(), l.getPaymentDate());
        }
    }
}
