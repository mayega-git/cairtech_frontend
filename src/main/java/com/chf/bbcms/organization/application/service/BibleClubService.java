package com.chf.bbcms.organization.application.service;

import com.chf.bbcms.organization.application.port.in.ManageBibleClubUseCase;
import com.chf.bbcms.organization.application.port.out.BibleClubRepository;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class BibleClubService implements ManageBibleClubUseCase {

    private final BibleClubRepository repository;

    public BibleClubService(BibleClubRepository repository) {
        this.repository = repository;
    }

    @Override
    public Mono<BibleClub> create(CreateBibleClubCommand cmd) {
        BibleClub b = BibleClub.create(cmd.name(), cmd.profile(), cmd.schoolName(),
                cmd.goalNbFaithful(), cmd.dateCreated());
        if (cmd.imageFileId() != null) b.setImageFileId(cmd.imageFileId());
        return repository.save(b);
    }

    @Override
    public Mono<BibleClub> setImage(UUID id, UUID imageFileId) {
        return findById(id).flatMap(b -> { b.setImageFileId(imageFileId); return repository.save(b); });
    }

    @Override
    public Mono<BibleClub> update(UUID id, UpdateBibleClubCommand cmd) {
        return findById(id).flatMap(b -> {
            if (cmd.name() != null) b.rename(cmd.name());
            // profile/schoolName: pas de méthode mutator dans le domaine — pour rester
            // strict côté domaine, on ajouterait des setters surveillés. À court terme
            // on persiste en passant par un nouveau create + champs. Simple V1: rename only.
            return repository.save(b);
        });
    }

    @Override
    public Mono<BibleClub> setGoal(UUID id, int goalNbFaithful) {
        return findById(id).flatMap(b -> { b.setGoalNbFaithful(goalNbFaithful); return repository.save(b); });
    }

    @Override
    public Mono<BibleClub> assignTriumvirate(UUID id, UUID presidentId, UUID vicePresidentId, UUID secretaryId) {
        return findById(id).flatMap(b -> {
            b.assignPresident(presidentId);
            b.assignVicePresident(vicePresidentId);
            b.assignSecretary(secretaryId);
            return repository.save(b);
        });
    }

    @Override
    public Mono<BibleClub> findById(UUID id) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("BibleClub", id)));
    }

    @Override
    public Flux<BibleClub> listAll() { return repository.findAll(); }

    @Override
    public Mono<Void> deleteById(UUID id) { return repository.deleteById(id); }
}
