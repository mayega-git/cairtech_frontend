package com.chf.bbcms.discipleship.adapter.out.persistence;

import com.chf.bbcms.discipleship.application.port.out.DiscipleshipRecordRepository;
import com.chf.bbcms.discipleship.domain.DiscipleshipRecord;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.HashSet;
import java.util.UUID;

@Repository
public class R2dbcDiscipleshipRecordRepository implements DiscipleshipRecordRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcDiscipleshipRecordRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<DiscipleshipRecord> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), DiscipleshipRecordRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<DiscipleshipRecord> findByMaker(UUID makerId) {
        return template.select(DiscipleshipRecordRow.class)
                .matching(Query.query(Criteria.where("disciple_maker_member_id").is(makerId)))
                .all().flatMap(this::toDomain);
    }

    @Override
    public Mono<DiscipleshipRecord> save(DiscipleshipRecord r) {
        DiscipleshipRecordRow row = toRow(r);
        Mono<DiscipleshipRecordRow> saved = (row.getId() == null ? template.insert(row) : template.update(row));
        return saved.flatMap(persisted -> persistPresent(persisted.getId(), r).thenReturn(persisted))
                .flatMap(this::toDomain);
    }

    private Mono<Void> persistPresent(UUID id, DiscipleshipRecord r) {
        return client.sql("DELETE FROM bbcms_discipleship_present WHERE record_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(r.getPresentDiscipleIds()).flatMap(d ->
                        client.sql("INSERT INTO bbcms_discipleship_present(record_id, disciple_member_id) VALUES(:r, :d)")
                                .bind("r", id).bind("d", d).then()))
                .then();
    }

    private Mono<DiscipleshipRecord> toDomain(DiscipleshipRecordRow r) {
        return client.sql("SELECT disciple_member_id FROM bbcms_discipleship_present WHERE record_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("disciple_member_id", UUID.class))
                .all().collect(HashSet<UUID>::new, HashSet::add)
                .map(present -> DiscipleshipRecord.rehydrate(r.getId(), r.getDiscipleMakerMemberId(),
                        r.getMeetingId(), r.getDateOccurred(), r.getStartTime(), r.getEndTime(),
                        r.getTheme(), r.getLocation(), r.getMeetingDescription(),
                        r.getDisciplesStateText(), r.getSpiritualInvestmentText(),
                        present, r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()));
    }

    private DiscipleshipRecordRow toRow(DiscipleshipRecord rec) {
        DiscipleshipRecordRow r = new DiscipleshipRecordRow();
        r.setId(rec.getId());
        r.setDiscipleMakerMemberId(rec.getDiscipleMakerMemberId());
        r.setMeetingId(rec.getMeetingId().orElse(null));
        r.setDateOccurred(rec.getDateOccurred());
        r.setStartTime(rec.getStartTime());
        r.setEndTime(rec.getEndTime());
        r.setTheme(rec.getTheme());
        r.setLocation(rec.getLocation());
        r.setMeetingDescription(rec.getMeetingDescription());
        r.setDisciplesStateText(rec.getDisciplesStateText());
        r.setSpiritualInvestmentText(rec.getSpiritualInvestmentText());
        Instant now = Instant.now();
        if (rec.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(rec.getCreatedBy() == null ? SYSTEM : rec.getCreatedBy());
            r.setCreatedAt(rec.getCreatedAt() == null ? now : rec.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(rec.getVersion());
        return r;
    }
}
