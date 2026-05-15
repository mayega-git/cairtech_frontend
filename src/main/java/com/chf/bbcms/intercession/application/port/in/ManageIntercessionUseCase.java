package com.chf.bbcms.intercession.application.port.in;

import com.chf.bbcms.intercession.domain.PrayerChain;
import com.chf.bbcms.intercession.domain.PrayerSlot;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public interface ManageIntercessionUseCase {

    Mono<PrayerChain> draftChain(UUID bibleClubId, String title, LocalDate start, LocalDate end);
    Mono<PrayerChain> startChain(UUID chainId);
    Mono<PrayerChain> closeChain(UUID chainId);
    Flux<PrayerChain> listByBibleClub(UUID bibleClubId);

    Mono<PrayerSlot> addSlot(UUID chainId, Instant start, Instant end);
    Mono<PrayerSlot> coverSlot(UUID slotId, UUID intercessorMemberId, String note);
    Mono<PrayerSlot> uncoverSlot(UUID slotId);
    Flux<PrayerSlot> listSlotsByChain(UUID chainId);
}
