package com.chf.bbcms.intercession.adapter.out.persistence;

import com.chf.bbcms.intercession.application.port.out.PrayerChainRepository;
import com.chf.bbcms.intercession.domain.PrayerChain;
import com.chf.bbcms.intercession.domain.PrayerChainStatus;
import com.chf.bbcms.intercession.domain.PrayerSlot;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public class R2dbcPrayerChainRepository implements PrayerChainRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcPrayerChainRepository(R2dbcEntityTemplate template) { this.template = template; }

    @Override
    public Mono<PrayerChain> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), PrayerChainRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<PrayerChain> findByBibleClub(UUID bibleClubId) {
        return template.select(PrayerChainRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all().map(this::toDomain);
    }

    @Override
    public Mono<PrayerChain> save(PrayerChain c) {
        PrayerChainRow row = new PrayerChainRow();
        row.setId(c.getId());
        row.setBibleClubId(c.getBibleClubId());
        row.setTitle(c.getTitle());
        row.setDateStart(c.getDateStart());
        row.setDateEnd(c.getDateEnd());
        row.setStatus(c.getStatus().name());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<PrayerSlot> findSlotById(UUID slotId) {
        return template.selectOne(Query.query(Criteria.where("id").is(slotId)), PrayerSlotRow.class)
                .map(this::toDomainSlot);
    }

    @Override
    public Flux<PrayerSlot> findSlotsByChain(UUID chainId) {
        return template.select(PrayerSlotRow.class)
                .matching(Query.query(Criteria.where("prayer_chain_id").is(chainId)))
                .all().map(this::toDomainSlot);
    }

    @Override
    public Mono<PrayerSlot> saveSlot(PrayerSlot s) {
        PrayerSlotRow row = new PrayerSlotRow();
        row.setId(s.getId());
        row.setPrayerChainId(s.getPrayerChainId());
        row.setIntercessorMemberId(s.getIntercessorMemberId().orElse(null));
        row.setDtStart(s.getDtStart());
        row.setDtEnd(s.getDtEnd());
        row.setCovered(s.isCovered());
        row.setNote(s.getNote());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomainSlot);
    }

    private PrayerChain toDomain(PrayerChainRow r) {
        return PrayerChain.rehydrate(r.getId(), r.getBibleClubId(), r.getTitle(),
                r.getDateStart(), r.getDateEnd(), PrayerChainStatus.valueOf(r.getStatus()));
    }

    private PrayerSlot toDomainSlot(PrayerSlotRow r) {
        return PrayerSlot.rehydrate(r.getId(), r.getPrayerChainId(), r.getIntercessorMemberId(),
                r.getDtStart(), r.getDtEnd(), r.isCovered(), r.getNote());
    }
}
