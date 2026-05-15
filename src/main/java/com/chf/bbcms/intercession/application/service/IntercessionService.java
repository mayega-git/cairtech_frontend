package com.chf.bbcms.intercession.application.service;

import com.chf.bbcms.intercession.application.port.in.ManageIntercessionUseCase;
import com.chf.bbcms.intercession.application.port.out.PrayerChainRepository;
import com.chf.bbcms.intercession.domain.PrayerChain;
import com.chf.bbcms.intercession.domain.PrayerSlot;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Service
public class IntercessionService implements ManageIntercessionUseCase {

    private final PrayerChainRepository repository;

    public IntercessionService(PrayerChainRepository repository) { this.repository = repository; }

    @Override
    public Mono<PrayerChain> draftChain(UUID bibleClubId, String title, LocalDate start, LocalDate end) {
        return repository.save(PrayerChain.draft(bibleClubId, title, start, end));
    }

    @Override
    public Mono<PrayerChain> startChain(UUID chainId) {
        return loadChain(chainId).flatMap(c -> { c.start(); return repository.save(c); });
    }

    @Override
    public Mono<PrayerChain> closeChain(UUID chainId) {
        return loadChain(chainId).flatMap(c -> { c.close(); return repository.save(c); });
    }

    @Override
    public Flux<PrayerChain> listByBibleClub(UUID bibleClubId) {
        return repository.findByBibleClub(bibleClubId);
    }

    @Override
    public Mono<PrayerSlot> addSlot(UUID chainId, Instant start, Instant end) {
        return repository.saveSlot(PrayerSlot.create(chainId, start, end));
    }

    @Override
    public Mono<PrayerSlot> coverSlot(UUID slotId, UUID intercessorMemberId, String note) {
        return loadSlot(slotId).flatMap(s -> {
            s.cover(intercessorMemberId, note);
            return repository.saveSlot(s);
        });
    }

    @Override
    public Mono<PrayerSlot> uncoverSlot(UUID slotId) {
        return loadSlot(slotId).flatMap(s -> { s.uncover(); return repository.saveSlot(s); });
    }

    @Override
    public Flux<PrayerSlot> listSlotsByChain(UUID chainId) {
        return repository.findSlotsByChain(chainId);
    }

    private Mono<PrayerChain> loadChain(UUID id) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("PrayerChain", id)));
    }

    private Mono<PrayerSlot> loadSlot(UUID id) {
        return repository.findSlotById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("PrayerSlot", id)));
    }
}
