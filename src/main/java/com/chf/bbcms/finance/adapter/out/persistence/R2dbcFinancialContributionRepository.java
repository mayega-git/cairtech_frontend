package com.chf.bbcms.finance.adapter.out.persistence;

import com.chf.bbcms.finance.application.port.out.FinancialContributionRepository;
import com.chf.bbcms.finance.domain.ContributionLine;
import com.chf.bbcms.finance.domain.ContributionStatus;
import com.chf.bbcms.finance.domain.FinancialContribution;
import com.chf.bbcms.finance.domain.PaymentChannel;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcFinancialContributionRepository implements FinancialContributionRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcFinancialContributionRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<FinancialContribution> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), FinancialContributionRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<FinancialContribution> findByBibleClub(UUID bibleClubId) {
        return template.select(FinancialContributionRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<FinancialContribution> save(FinancialContribution c) {
        FinancialContributionRow row = toRow(c);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Flux<ContributionLine> findLinesByContribution(UUID contributionId) {
        return template.select(ContributionLineRow.class)
                .matching(Query.query(Criteria.where("contribution_id").is(contributionId)))
                .all().map(this::toDomainLine);
    }

    @Override
    public Mono<ContributionLine> saveLine(ContributionLine l) {
        ContributionLineRow row = new ContributionLineRow();
        row.setId(l.getId());
        row.setContributionId(l.getContributionId());
        row.setContributorMemberId(l.getContributorMemberId().orElse(null));
        row.setContributorName(l.getContributorName());
        row.setAmount(l.getAmount());
        row.setPaymentChannel(l.getPaymentChannel().name());
        row.setPaymentReference(l.getPaymentReference());
        row.setPaymentDate(l.getPaymentDate());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomainLine);
    }

    private FinancialContribution toDomain(FinancialContributionRow r) {
        return FinancialContribution.rehydrate(r.getId(), r.getBibleClubId(), r.getTitle(),
                r.getDescription(), r.getObjectiveAmount(), r.getCurrency(),
                r.getDateOpen(), r.getDateClose(),
                ContributionStatus.valueOf(r.getStatus()), r.getTotalContributed());
    }

    private ContributionLine toDomainLine(ContributionLineRow r) {
        return ContributionLine.rehydrate(r.getId(), r.getContributionId(), r.getContributorMemberId(),
                r.getContributorName(), r.getAmount(),
                PaymentChannel.valueOf(r.getPaymentChannel()),
                r.getPaymentReference(), r.getPaymentDate());
    }

    private FinancialContributionRow toRow(FinancialContribution c) {
        FinancialContributionRow r = new FinancialContributionRow();
        r.setId(c.getId());
        r.setBibleClubId(c.getBibleClubId());
        r.setTitle(c.getTitle());
        r.setDescription(c.getDescription());
        r.setObjectiveAmount(c.getObjectiveAmount());
        r.setCurrency(c.getCurrency());
        r.setDateOpen(c.getDateOpen());
        r.setDateClose(c.getDateClose());
        r.setStatus(c.getStatus().name());
        r.setTotalContributed(c.getTotalContributed());
        return r;
    }
}
