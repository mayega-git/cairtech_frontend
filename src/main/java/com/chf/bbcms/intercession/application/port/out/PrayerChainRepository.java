package com.chf.bbcms.intercession.application.port.out;

import com.chf.bbcms.intercession.domain.PrayerChain;
import com.chf.bbcms.intercession.domain.PrayerSlot;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface PrayerChainRepository {
    Mono<PrayerChain> findById(UUID id);
    Flux<PrayerChain> findByBibleClub(UUID bibleClubId);
    Mono<PrayerChain> save(PrayerChain chain);

    Mono<PrayerSlot> findSlotById(UUID slotId);
    Flux<PrayerSlot> findSlotsByChain(UUID chainId);
    Mono<PrayerSlot> saveSlot(PrayerSlot slot);
}
