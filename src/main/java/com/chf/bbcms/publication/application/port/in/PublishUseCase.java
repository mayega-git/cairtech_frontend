package com.chf.bbcms.publication.application.port.in;

import com.chf.bbcms.publication.domain.AnnouncementType;
import com.chf.bbcms.publication.domain.DailyVersePublication;
import com.chf.bbcms.publication.domain.PublicationAudience;
import com.chf.bbcms.publication.domain.SpecialAnnouncement;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

public interface PublishUseCase {

    Mono<DailyVersePublication> draftDailyVerse(String title, String reference, String verseText,
                                                String reflectionText, UUID imageFileId,
                                                LocalDate publishDate, PublicationAudience audience);
    Mono<DailyVersePublication> publishDailyVerseNow(UUID id);
    Flux<DailyVersePublication> listDailyVerses();
    Mono<DailyVersePublication> findDailyVerse(UUID id);

    Mono<SpecialAnnouncement> draftAnnouncement(String title, String content, UUID imageFileId,
                                                AnnouncementType type, LocalDate publishDate,
                                                PublicationAudience audience);
    Mono<SpecialAnnouncement> publishAnnouncementNow(UUID id);
    Flux<SpecialAnnouncement> listAnnouncements();
}
