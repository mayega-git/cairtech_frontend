package com.chf.bbcms.reset.application.service;

import com.chf.bbcms.attendance.application.port.out.AttendanceScoreRepository;
import com.chf.bbcms.organization.application.port.out.BibleClubRepository;
import com.chf.bbcms.organization.application.port.out.LevelRepository;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.organization.domain.Level;
import com.chf.bbcms.organization.domain.LevelType;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.Member;
import com.chf.bbcms.people.domain.MemberKind;
import com.chf.bbcms.people.domain.MemberStatus;
import com.chf.bbcms.reset.application.port.in.ResetBibleClubUseCase;
import com.chf.bbcms.reset.application.port.out.ResetSnapshotRepository;
import com.chf.bbcms.reset.application.port.out.SnapshotRendererPort;
import com.chf.bbcms.reset.application.port.out.SnapshotRendererPort.RenderedDocument;
import com.chf.bbcms.reset.domain.BibleClubReset;
import com.chf.bbcms.reset.domain.BibleClubResetSnapshot;
import com.chf.bbcms.reset.domain.TransferRule;
import com.chf.bbcms.shared.domain.NotFoundException;
import com.chf.bbcms.shared.outbox.DomainEventBus;
import com.chf.bbcms.storage.application.port.out.FileStoragePort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.io.ByteArrayInputStream;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Workflow saga de réinitialisation annuelle d'un Bible Club.
 *
 * Étapes (cf. DS-BBCMS-07):
 *   1. Lock du BBC en UNDER_RESET (gel des écritures, RM-07)
 *   2. Génération du snapshot (membres, fidèles, meetings, % objectif)
 *   3. Archive textuelle uploadée dans MinIO (V1: TXT — PDF en V2)
 *   4. Transferts: L1→L2, ..., L6→L7, L7→TRANSFERRED
 *   5. Reset des AttendanceScore à 0 pour la nouvelle année
 *   6. BBC repasse ACTIVE
 *   7. Publication BBC_RESET sur l'outbox
 */
@Service
public class ResetService implements ResetBibleClubUseCase {

    private static final Logger log = LoggerFactory.getLogger(ResetService.class);

    private final BibleClubRepository bibleClubRepository;
    private final LevelRepository levelRepository;
    private final MemberRepository memberRepository;
    private final AttendanceScoreRepository scoreRepository;
    private final ResetSnapshotRepository snapshotRepository;
    private final FileStoragePort fileStorage;
    private final SnapshotRendererPort snapshotRenderer;
    private final DomainEventBus eventBus;
    private final TransactionalOperator txOperator;

    public ResetService(BibleClubRepository bibleClubRepository,
                        LevelRepository levelRepository,
                        MemberRepository memberRepository,
                        AttendanceScoreRepository scoreRepository,
                        ResetSnapshotRepository snapshotRepository,
                        FileStoragePort fileStorage,
                        SnapshotRendererPort snapshotRenderer,
                        DomainEventBus eventBus,
                        TransactionalOperator txOperator) {
        this.bibleClubRepository = bibleClubRepository;
        this.levelRepository = levelRepository;
        this.memberRepository = memberRepository;
        this.scoreRepository = scoreRepository;
        this.snapshotRepository = snapshotRepository;
        this.fileStorage = fileStorage;
        this.snapshotRenderer = snapshotRenderer;
        this.eventBus = eventBus;
        this.txOperator = txOperator;
    }

    @Override
    public Mono<BibleClubResetSnapshot> reset(UUID bibleClubId, int academicYear, UUID actorId) {
        log.info("Starting reset of BBC {} for year {}", bibleClubId, academicYear);
        return loadBbc(bibleClubId)
                .flatMap(bbc -> {
                    bbc.startReset();
                    return bibleClubRepository.save(bbc);
                })
                .flatMap(bbc -> buildLevelMap(bibleClubId)
                        .flatMap(levelMap -> aggregateStats(bbc, academicYear)
                                .flatMap(stats -> {
                                    BibleClubResetSnapshot snap = BibleClubResetSnapshot.capture(
                                            bbc.getId(), academicYear,
                                            stats.nbMembers, stats.nbFaithful, stats.nbMeetings,
                                            bbc.getGoalNbFaithful(), actorId);
                                    return archiveSnapshot(bbc, snap)
                                            .flatMap(snapshotRepository::save)
                                            .flatMap(saved -> applyTransfers(bibleClubId, levelMap)
                                                    .then(scoreRepository.resetByBibleClubAndYear(bibleClubId, academicYear))
                                                    .then(reactivateBbc(bbc))
                                                    .then(eventBus.publish(new BibleClubReset(
                                                            bbc.getId(), academicYear,
                                                            stats.nbMembers, stats.nbFaithful,
                                                            saved.archiveFileId(), saved.id(),
                                                            Instant.now())))
                                                    .thenReturn(saved));
                                })))
                .as(txOperator::transactional)
                .doOnSuccess(s -> log.info("Reset completed for BBC {} (year {}, archive {})",
                        bibleClubId, academicYear, s.archiveFileId()));
    }

    private Mono<BibleClub> loadBbc(UUID id) {
        return bibleClubRepository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("BibleClub", id)));
    }

    private Mono<Map<UUID, LevelType>> buildLevelMap(UUID bibleClubId) {
        return levelRepository.findByBibleClubId(bibleClubId)
                .collectMap(Level::getId, Level::getType);
    }

    private record Stats(int nbMembers, int nbFaithful, int nbMeetings) {}

    private Mono<Stats> aggregateStats(BibleClub bbc, int academicYear) {
        Mono<Long> members = memberRepository.findByBibleClub(bbc.getId())
                .filter(m -> m.getKind() == MemberKind.STUDENT && m.getStatus() == MemberStatus.ACTIVE)
                .count();
        Mono<Long> faithful = scoreRepository.findByBibleClubAndYear(bbc.getId(), academicYear)
                .filter(s -> s.isFaithful())
                .count();
        return Mono.zip(members, faithful)
                .map(t -> new Stats(t.getT1().intValue(), t.getT2().intValue(), 0));
    }

    private Mono<BibleClubResetSnapshot> archiveSnapshot(BibleClub bbc, BibleClubResetSnapshot snap) {
        RenderedDocument doc = snapshotRenderer.render(bbc, snap);
        FileStoragePort.StoreRequest req = new FileStoragePort.StoreRequest(
                doc.fileName(), doc.contentType(), doc.bytes().length,
                new ByteArrayInputStream(doc.bytes()));
        return fileStorage.store(req).map(snap::withArchiveFileId);
    }

    private Mono<Void> applyTransfers(UUID bibleClubId, Map<UUID, LevelType> levelMap) {
        Map<LevelType, UUID> levelIdByType = new HashMap<>();
        levelMap.forEach((id, type) -> levelIdByType.put(type, id));

        return memberRepository.findByBibleClub(bibleClubId)
                .filter(m -> m.getKind() == MemberKind.STUDENT && m.getStatus() == MemberStatus.ACTIVE)
                .flatMap(member -> applyTransfer(member, levelMap, levelIdByType))
                .then();
    }

    private Mono<Member> applyTransfer(Member member, Map<UUID, LevelType> levelMap,
                                       Map<LevelType, UUID> levelIdByType) {
        LevelType current = member.getLevelId().map(levelMap::get).orElse(null);
        if (current == null) return Mono.empty();
        if (TransferRule.isGraduating(current)) {
            member.markTransferred();
            return memberRepository.save(member);
        }
        Optional<LevelType> next = TransferRule.nextLevelFor(current);
        if (next.isEmpty()) return Mono.empty();
        UUID nextLevelId = levelIdByType.get(next.get());
        if (nextLevelId == null) {
            log.warn("Cannot transfer member {}: target level {} missing in BBC", member.getId(), next.get());
            return Mono.empty();
        }
        member.transferLevel(nextLevelId);
        return memberRepository.save(member);
    }

    private Mono<BibleClub> reactivateBbc(BibleClub bbc) {
        bbc.finishReset();
        return bibleClubRepository.save(bbc);
    }
}
