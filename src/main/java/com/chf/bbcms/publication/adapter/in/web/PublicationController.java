package com.chf.bbcms.publication.adapter.in.web;

import com.chf.bbcms.publication.application.port.in.PublishUseCase;
import com.chf.bbcms.publication.domain.AnnouncementType;
import com.chf.bbcms.publication.domain.DailyVersePublication;
import com.chf.bbcms.publication.domain.PublicationAudience;
import com.chf.bbcms.publication.domain.SpecialAnnouncement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/publications")
public class PublicationController {

    private final PublishUseCase useCase;

    public PublicationController(PublishUseCase useCase) { this.useCase = useCase; }

    @PostMapping("/daily-verses")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:publication:daily-verse')")
    public Mono<VerseResponse> draftVerse(@Valid @RequestBody DraftVerseRequest req) {
        return useCase.draftDailyVerse(req.title(), req.reference(), req.verseText(),
                        req.reflectionText(), req.imageFileId(), req.publishDate(), req.audience())
                .map(VerseResponse::from);
    }

    @PostMapping("/daily-verses/{id}/publish")
    @PreAuthorize("hasAuthority('bbcms:publication:daily-verse')")
    public Mono<VerseResponse> publishVerse(@PathVariable UUID id) {
        return useCase.publishDailyVerseNow(id).map(VerseResponse::from);
    }

    @GetMapping("/daily-verses")
    @PreAuthorize("hasAuthority('bbcms:publication:read')")
    public Flux<VerseResponse> listVerses() {
        return useCase.listDailyVerses().map(VerseResponse::from);
    }

    @GetMapping("/daily-verses/{id}")
    @PreAuthorize("hasAuthority('bbcms:publication:read')")
    public Mono<VerseResponse> getVerse(@PathVariable UUID id) {
        return useCase.findDailyVerse(id).map(VerseResponse::from);
    }

    @PostMapping("/announcements")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('bbcms:publication:announcement')")
    public Mono<AnnouncementResponse> draftAnnouncement(@Valid @RequestBody DraftAnnouncementRequest req) {
        return useCase.draftAnnouncement(req.title(), req.content(), req.imageFileId(),
                        req.type(), req.publishDate(), req.audience())
                .map(AnnouncementResponse::from);
    }

    @PostMapping("/announcements/{id}/publish")
    @PreAuthorize("hasAuthority('bbcms:publication:announcement')")
    public Mono<AnnouncementResponse> publishAnnouncement(@PathVariable UUID id) {
        return useCase.publishAnnouncementNow(id).map(AnnouncementResponse::from);
    }

    @GetMapping("/announcements")
    @PreAuthorize("hasAuthority('bbcms:publication:read')")
    public Flux<AnnouncementResponse> listAnnouncements() {
        return useCase.listAnnouncements().map(AnnouncementResponse::from);
    }

    public record DraftVerseRequest(@NotBlank String title, @NotBlank String reference,
                                    @NotBlank String verseText, String reflectionText,
                                    UUID imageFileId, @NotNull LocalDate publishDate,
                                    PublicationAudience audience) {}
    public record DraftAnnouncementRequest(@NotBlank String title, @NotBlank String content,
                                           UUID imageFileId, @NotNull AnnouncementType type,
                                           @NotNull LocalDate publishDate, PublicationAudience audience) {}

    public record VerseResponse(UUID id, String title, String reference, String verseText,
                                String reflectionText, UUID imageFileId, LocalDate publishDate,
                                String status, String audience) {
        static VerseResponse from(DailyVersePublication p) {
            return new VerseResponse(p.getId(), p.getTitle(), p.getReference(), p.getVerseText(),
                    p.getReflectionText(), p.getImageFileId().orElse(null),
                    p.getPublishDate(), p.getStatus().name(), p.getAudience().name());
        }
    }

    public record AnnouncementResponse(UUID id, String title, String content, UUID imageFileId,
                                       String type, LocalDate publishDate, String status, String audience) {
        static AnnouncementResponse from(SpecialAnnouncement a) {
            return new AnnouncementResponse(a.getId(), a.getTitle(), a.getContent(),
                    a.getImageFileId().orElse(null), a.getType().name(), a.getPublishDate(),
                    a.getStatus().name(), a.getAudience().name());
        }
    }
}
