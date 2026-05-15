package com.chf.bbcms.reset.adapter.out.persistence;

import com.chf.bbcms.reset.application.port.out.ResetSnapshotRepository;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcResetSnapshotRepository implements ResetSnapshotRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcResetSnapshotRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Mono<BibleClubResetSnapshot> save(BibleClubResetSnapshot s) {
        ResetSnapshotRow row = new ResetSnapshotRow();
        row.setId(s.id());
        row.setBibleClubId(s.bibleClubId());
        row.setAcademicYear(s.academicYear());
        row.setNbMembersBefore(s.nbMembersBefore());
        row.setNbFaithfulBefore(s.nbFaithfulBefore());
        row.setNbMeetings(s.nbMeetings());
        row.setPercentageReached(s.percentageReached());
        row.setArchivedAt(s.archivedAt() == null ? Instant.now() : s.archivedAt());
        row.setArchiveFileId(s.archiveFileId());
        row.setCreatedBy(s.createdBy());
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<BibleClubResetSnapshot> findByBibleClubAndYear(UUID bibleClubId, int academicYear) {
        return template.selectOne(Query.query(Criteria.where("bible_club_id").is(bibleClubId)
                                .and("academic_year").is(academicYear)),
                        ResetSnapshotRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<BibleClubResetSnapshot> findByBibleClub(UUID bibleClubId) {
        return template.select(ResetSnapshotRow.class)
                .matching(Query.query(Criteria.where("bible_club_id").is(bibleClubId)))
                .all().map(this::toDomain);
    }

    private BibleClubResetSnapshot toDomain(ResetSnapshotRow r) {
        return new BibleClubResetSnapshot(r.getId(), r.getBibleClubId(), r.getAcademicYear(),
                r.getNbMembersBefore(), r.getNbFaithfulBefore(), r.getNbMeetings(),
                r.getPercentageReached(), r.getArchivedAt(), r.getArchiveFileId(), r.getCreatedBy());
    }
}
