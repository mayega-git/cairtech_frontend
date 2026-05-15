package com.chf.bbcms.publication.application.port.out;

import com.chf.bbcms.publication.domain.DailyVersePublication;
import com.chf.bbcms.publication.domain.SpecialAnnouncement;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface PublicationRepository {
    Mono<DailyVersePublication> findVerseById(UUID id);
    Flux<DailyVersePublication> findVerses();
    Mono<DailyVersePublication> save(DailyVersePublication p);

    Mono<SpecialAnnouncement> findAnnouncementById(UUID id);
    Flux<SpecialAnnouncement> findAnnouncements();
    Mono<SpecialAnnouncement> save(SpecialAnnouncement a);
}
