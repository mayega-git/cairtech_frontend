package com.chf.bbcms.organization.adapter.in.web;

import com.chf.bbcms.organization.application.port.in.ManageBibleClubUseCase;
import com.chf.bbcms.organization.application.port.in.ManageLevelUseCase;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.organization.domain.Level;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.util.UUID;

/**
 * Endpoints publics utilisés par le formulaire d'inscription pour proposer
 * des sélecteurs (Bible Clubs / Niveaux) sans imposer de connexion préalable.
 *
 * Données minimales (id + libellé) — pas de données sensibles.
 */
@RestController
@RequestMapping("/api/v1/bbcms/public")
public class PublicRegistryController {

    private final ManageBibleClubUseCase bibleClubUseCase;
    private final ManageLevelUseCase levelUseCase;

    public PublicRegistryController(ManageBibleClubUseCase bibleClubUseCase,
                                    ManageLevelUseCase levelUseCase) {
        this.bibleClubUseCase = bibleClubUseCase;
        this.levelUseCase = levelUseCase;
    }

    @GetMapping("/bible-clubs")
    public Flux<BibleClubLite> listBibleClubs() {
        return bibleClubUseCase.listAll().map(BibleClubLite::from);
    }

    @GetMapping("/bible-clubs/{bibleClubId}/levels")
    public Flux<LevelLite> listLevels(@PathVariable UUID bibleClubId) {
        return levelUseCase.listByBibleClub(bibleClubId).map(LevelLite::from);
    }

    public record BibleClubLite(UUID id, String name, String schoolName) {
        static BibleClubLite from(BibleClub b) {
            return new BibleClubLite(b.getId(), b.getName(), b.getSchoolName());
        }
    }

    public record LevelLite(UUID id, String name, String type) {
        static LevelLite from(Level l) {
            return new LevelLite(l.getId(), l.getName(), l.getType().name());
        }
    }
}
