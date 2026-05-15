package com.chf.bbcms.evangelism.adapter.out.persistence;

import com.chf.bbcms.evangelism.application.port.out.EvangelismRecordRepository;
import com.chf.bbcms.evangelism.domain.EvangelismRecord;
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
public class R2dbcEvangelismRecordRepository implements EvangelismRecordRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcEvangelismRecordRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<EvangelismRecord> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), EvangelismRecordRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<EvangelismRecord> findByProgram(UUID programId) {
        return template.select(EvangelismRecordRow.class)
                .matching(Query.query(Criteria.where("program_id").is(programId)))
                .all().flatMap(this::toDomain);
    }

    @Override
    public Mono<EvangelismRecord> save(EvangelismRecord r) {
        EvangelismRecordRow row = toRow(r);
        Mono<EvangelismRecordRow> saved = (row.getId() == null ? template.insert(row) : template.update(row));
        return saved.flatMap(persisted -> persistParticipants(persisted.getId(), r).thenReturn(persisted))
                .flatMap(this::toDomain);
    }

    private Mono<Void> persistParticipants(UUID id, EvangelismRecord r) {
        return client.sql("DELETE FROM bbcms_evangelism_record_participants WHERE record_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(r.getParticipantMemberIds()).flatMap(p ->
                        client.sql("INSERT INTO bbcms_evangelism_record_participants(record_id, member_id) VALUES(:r, :m)")
                                .bind("r", id).bind("m", p).then()))
                .then();
    }

    private Mono<EvangelismRecord> toDomain(EvangelismRecordRow r) {
        return client.sql("SELECT member_id FROM bbcms_evangelism_record_participants WHERE record_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("member_id", UUID.class))
                .all().collect(HashSet<UUID>::new, HashSet::add)
                .map(parts -> EvangelismRecord.rehydrate(r.getId(), r.getProgramId(), r.getRecordDate(),
                        r.getNbPreached(), r.getNbBelieved(), r.getNbEncouraged(), r.getNbTractsShared(),
                        r.getSavedContacts(), r.getNotes(), parts,
                        r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()));
    }

    private EvangelismRecordRow toRow(EvangelismRecord rec) {
        EvangelismRecordRow r = new EvangelismRecordRow();
        r.setId(rec.getId());
        r.setProgramId(rec.getProgramId());
        r.setRecordDate(rec.getRecordDate());
        r.setNbPreached(rec.getNbPreached());
        r.setNbBelieved(rec.getNbBelieved());
        r.setNbEncouraged(rec.getNbEncouraged());
        r.setNbTractsShared(rec.getNbTractsShared());
        r.setSavedContacts(rec.getSavedContacts());
        r.setNotes(rec.getNotes());
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
