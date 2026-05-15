package com.chf.bbcms.publication.application.service;

import com.chf.bbcms.publication.application.port.in.PublishUseCase;
import com.chf.bbcms.publication.application.port.out.PublicationRepository;
import com.chf.bbcms.publication.domain.AnnouncementType;
import com.chf.bbcms.publication.domain.DailyVersePublication;
import com.chf.bbcms.publication.domain.PublicationAudience;
import com.chf.bbcms.publication.domain.SpecialAnnouncement;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@Service
public class PublicationService implements PublishUseCase {

    private final PublicationRepository repository;

    public PublicationService(PublicationRepository repository) { this.repository = repository; }

    @Override
    public Mono<DailyVersePublication> draftDailyVerse(String title, String reference, String verseText,
                                                       String reflectionText, UUID imageFileId,
                                                       LocalDate publishDate, PublicationAudience audience) {
        return repository.save(DailyVersePublication.draft(title, reference, verseText,
                reflectionText, imageFileId, publishDate, audience));
    }

    @Override
    public Mono<DailyVersePublication> publishDailyVerseNow(UUID id) {
        return loadVerse(id).flatMap(p -> { p.publishNow(); return repository.save(p); });
    }

    @Override
    public Flux<DailyVersePublication> listDailyVerses() { return repository.findVerses(); }

    @Override
    public Mono<DailyVersePublication> findDailyVerse(UUID id) { return loadVerse(id); }

    @Override
    public Mono<SpecialAnnouncement> draftAnnouncement(String title, String content, UUID imageFileId,
                                                       AnnouncementType type, LocalDate publishDate,
                                                       PublicationAudience audience) {
        return repository.save(SpecialAnnouncement.draft(title, content, imageFileId, type,
                publishDate, audience));
    }

    @Override
    public Mono<SpecialAnnouncement> publishAnnouncementNow(UUID id) {
        return loadAnnouncement(id).flatMap(a -> { a.publishNow(); return repository.save(a); });
    }

    @Override
    public Flux<SpecialAnnouncement> listAnnouncements() { return repository.findAnnouncements(); }

    private Mono<DailyVersePublication> loadVerse(UUID id) {
        return repository.findVerseById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("DailyVersePublication", id)));
    }

    private Mono<SpecialAnnouncement> loadAnnouncement(UUID id) {
        return repository.findAnnouncementById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("SpecialAnnouncement", id)));
    }
}
