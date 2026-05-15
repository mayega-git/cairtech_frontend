package com.chf.bbcms.evangelism.adapter.out.persistence;

import com.chf.bbcms.evangelism.application.port.out.EvangelismProgramRepository;
import com.chf.bbcms.evangelism.domain.EvangelismProgram;
import com.chf.bbcms.evangelism.domain.EvangelismProgramStatus;
import com.chf.bbcms.evangelism.domain.EvangelismProgramType;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.UUID;

@Repository
public class R2dbcEvangelismProgramRepository implements EvangelismProgramRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;
    private final DatabaseClient client;

    public R2dbcEvangelismProgramRepository(R2dbcEntityTemplate template, DatabaseClient client) {
        this.template = template;
        this.client = client;
    }

    @Override
    public Mono<EvangelismProgram> findById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), EvangelismProgramRow.class)
                .flatMap(this::toDomain);
    }

    @Override
    public Flux<EvangelismProgram> findAll() {
        return template.select(EvangelismProgramRow.class).all().flatMap(this::toDomain);
    }

    @Override
    public Mono<EvangelismProgram> save(EvangelismProgram p) {
        EvangelismProgramRow row = toRow(p);
        Mono<EvangelismProgramRow> saved = (row.getId() == null ? template.insert(row) : template.update(row));
        return saved.flatMap(persisted -> persistJoinTables(persisted.getId(), p).thenReturn(persisted))
                .flatMap(this::toDomain);
    }

    private Mono<Void> persistJoinTables(UUID id, EvangelismProgram p) {
        Mono<Void> dates = client.sql("DELETE FROM bbcms_evangelism_program_dates WHERE program_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(p.getDates()).flatMap(d ->
                        client.sql("INSERT INTO bbcms_evangelism_program_dates(program_id, program_date) VALUES(:p, :d)")
                                .bind("p", id).bind("d", d).then())).then();
        Mono<Void> bbcs = client.sql("DELETE FROM bbcms_evangelism_program_bbc WHERE program_id = :id")
                .bind("id", id).then()
                .thenMany(Flux.fromIterable(p.getBibleClubIds()).flatMap(b ->
                        client.sql("INSERT INTO bbcms_evangelism_program_bbc(program_id, bible_club_id) VALUES(:p, :b)")
                                .bind("p", id).bind("b", b).then())).then();
        return dates.then(bbcs);
    }

    private Mono<EvangelismProgram> toDomain(EvangelismProgramRow r) {
        Mono<HashSet<LocalDate>> dates = client.sql(
                        "SELECT program_date FROM bbcms_evangelism_program_dates WHERE program_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("program_date", LocalDate.class))
                .all().collect(HashSet<LocalDate>::new, HashSet::add);
        Mono<HashSet<UUID>> bbcs = client.sql(
                        "SELECT bible_club_id FROM bbcms_evangelism_program_bbc WHERE program_id = :id")
                .bind("id", r.getId())
                .map((row, m) -> row.get("bible_club_id", UUID.class))
                .all().collect(HashSet<UUID>::new, HashSet::add);
        return Mono.zip(dates, bbcs).map(t -> EvangelismProgram.rehydrate(
                r.getId(), r.getTitle(), EvangelismProgramType.valueOf(r.getType()),
                r.getObjectiveBelievers(), r.getTotalPreached(), r.getTotalSaved(),
                r.getTotalEncouraged(), EvangelismProgramStatus.valueOf(r.getStatus()),
                t.getT1(), t.getT2(), r.getCreatedAt(), r.getUpdatedAt(), r.getVersion()));
    }

    private EvangelismProgramRow toRow(EvangelismProgram p) {
        EvangelismProgramRow r = new EvangelismProgramRow();
        r.setId(p.getId());
        r.setTitle(p.getTitle());
        r.setType(p.getType().name());
        r.setObjectiveBelievers(p.getObjectiveBelievers());
        r.setTotalPreached(p.getTotalPreached());
        r.setTotalSaved(p.getTotalSaved());
        r.setTotalEncouraged(p.getTotalEncouraged());
        r.setStatus(p.getStatus().name());
        Instant now = Instant.now();
        if (p.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(p.getCreatedBy() == null ? SYSTEM : p.getCreatedBy());
            r.setCreatedAt(p.getCreatedAt() == null ? now : p.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(p.getVersion());
        return r;
    }
}
