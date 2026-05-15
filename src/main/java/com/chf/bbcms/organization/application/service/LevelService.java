package com.chf.bbcms.organization.application.service;

import com.chf.bbcms.organization.application.port.in.ManageLevelUseCase;
import com.chf.bbcms.organization.application.port.out.LevelRepository;
import com.chf.bbcms.organization.domain.Level;
import com.chf.bbcms.organization.domain.LevelType;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class LevelService implements ManageLevelUseCase {

    private final LevelRepository repository;

    public LevelService(LevelRepository repository) {
        this.repository = repository;
    }

    @Override
    public Mono<Level> create(UUID bibleClubId, String name, String profile, LevelType type) {
        return repository.save(Level.create(bibleClubId, name, profile, type));
    }

    @Override
    public Mono<Level> rename(UUID levelId, String newName) {
        return load(levelId).flatMap(l -> { l.rename(newName); return repository.save(l); });
    }

    @Override
    public Mono<Level> assignPresident(UUID levelId, UUID memberId) {
        return load(levelId).flatMap(l -> { l.assignPresident(memberId); return repository.save(l); });
    }

    @Override
    public Mono<Level> assignVicePresident(UUID levelId, UUID memberId) {
        return load(levelId).flatMap(l -> { l.assignVicePresident(memberId); return repository.save(l); });
    }

    @Override
    public Flux<Level> listByBibleClub(UUID bibleClubId) { return repository.findByBibleClubId(bibleClubId); }

    @Override
    public Mono<Void> deleteById(UUID levelId) { return repository.deleteById(levelId); }

    private Mono<Level> load(UUID id) {
        return repository.findById(id).switchIfEmpty(Mono.error(new NotFoundException("Level", id)));
    }
}
