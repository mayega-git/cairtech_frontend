package com.chf.bbcms.publication.adapter.out.persistence;

import com.chf.bbcms.publication.application.port.out.PublicationRepository;
import com.chf.bbcms.publication.domain.AnnouncementType;
import com.chf.bbcms.publication.domain.DailyVersePublication;
import com.chf.bbcms.publication.domain.PublicationAudience;
import com.chf.bbcms.publication.domain.PublicationStatus;
import com.chf.bbcms.publication.domain.SpecialAnnouncement;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Repository
public class R2dbcPublicationRepository implements PublicationRepository {

    private static final UUID SYSTEM = UUID.fromString("00000000-0000-0000-0000-000000000000");
    private final R2dbcEntityTemplate template;

    public R2dbcPublicationRepository(R2dbcEntityTemplate template) { this.template = template; }

    @Override
    public Mono<DailyVersePublication> findVerseById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), DailyVerseRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<DailyVersePublication> findVerses() {
        return template.select(DailyVerseRow.class).all().map(this::toDomain);
    }

    @Override
    public Mono<DailyVersePublication> save(DailyVersePublication p) {
        DailyVerseRow row = toRow(p);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    @Override
    public Mono<SpecialAnnouncement> findAnnouncementById(UUID id) {
        return template.selectOne(Query.query(Criteria.where("id").is(id)), SpecialAnnouncementRow.class)
                .map(this::toDomain);
    }

    @Override
    public Flux<SpecialAnnouncement> findAnnouncements() {
        return template.select(SpecialAnnouncementRow.class).all().map(this::toDomain);
    }

    @Override
    public Mono<SpecialAnnouncement> save(SpecialAnnouncement a) {
        SpecialAnnouncementRow row = toRow(a);
        return (row.getId() == null ? template.insert(row) : template.update(row)).map(this::toDomain);
    }

    private DailyVersePublication toDomain(DailyVerseRow r) {
        return DailyVersePublication.rehydrate(r.getId(), r.getTitle(), r.getReference(),
                r.getVerseText(), r.getReflectionText(), r.getImageFileId(),
                r.getPublishDate(), PublicationStatus.valueOf(r.getStatus()),
                PublicationAudience.valueOf(r.getAudience()),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private DailyVerseRow toRow(DailyVersePublication p) {
        DailyVerseRow r = new DailyVerseRow();
        r.setId(p.getId());
        r.setTitle(p.getTitle());
        r.setReference(p.getReference());
        r.setVerseText(p.getVerseText());
        r.setReflectionText(p.getReflectionText());
        r.setImageFileId(p.getImageFileId().orElse(null));
        r.setPublishDate(p.getPublishDate());
        r.setStatus(p.getStatus().name());
        r.setAudience(p.getAudience().name());
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

    private SpecialAnnouncement toDomain(SpecialAnnouncementRow r) {
        return SpecialAnnouncement.rehydrate(r.getId(), r.getTitle(), r.getContent(),
                r.getImageFileId(), AnnouncementType.valueOf(r.getType()),
                r.getPublishDate(), PublicationStatus.valueOf(r.getStatus()),
                PublicationAudience.valueOf(r.getAudience()),
                r.getCreatedAt(), r.getUpdatedAt(), r.getVersion());
    }

    private SpecialAnnouncementRow toRow(SpecialAnnouncement a) {
        SpecialAnnouncementRow r = new SpecialAnnouncementRow();
        r.setId(a.getId());
        r.setTitle(a.getTitle());
        r.setContent(a.getContent());
        r.setImageFileId(a.getImageFileId().orElse(null));
        r.setType(a.getType().name());
        r.setPublishDate(a.getPublishDate());
        r.setStatus(a.getStatus().name());
        r.setAudience(a.getAudience().name());
        Instant now = Instant.now();
        if (a.getId() == null) { r.setCreatedBy(SYSTEM); r.setCreatedAt(now); }
        else {
            r.setCreatedBy(a.getCreatedBy() == null ? SYSTEM : a.getCreatedBy());
            r.setCreatedAt(a.getCreatedAt() == null ? now : a.getCreatedAt());
        }
        r.setUpdatedBy(SYSTEM); r.setUpdatedAt(now);
        r.setVersion(a.getVersion());
        return r;
    }
}
