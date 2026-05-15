package com.chf.bbcms.sync.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.sync.application.port.in.SyncUseCase;
import com.chf.bbcms.sync.application.port.in.SyncUseCase.SyncBatch;
import com.chf.bbcms.sync.domain.SyncEntityKind;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.Instant;

/**
 * Endpoint de synchronisation pull pour les clients mobiles/desktop offline.
 *
 * Le client passe son deviceId via header X-Device-Id et l'entité à synchroniser.
 * Réponse: les changements depuis le dernier curseur (ou depuis 'since' si fourni).
 *
 * Pas de push de changements client → serveur en V2 — les écritures restent online
 * (le client maintient une queue locale et rejoue ses POST/PUT quand il revient online).
 */
@RestController
@RequestMapping("/api/v1/bbcms/sync")
public class MobileSyncController {

    private final SyncUseCase useCase;

    public MobileSyncController(SyncUseCase useCase) { this.useCase = useCase; }

    @GetMapping("/changes")
    public Mono<SyncBatch> pull(@RequestHeader("X-Device-Id") @NotBlank String deviceId,
                                @RequestParam("kind") SyncEntityKind kind,
                                @RequestParam(value = "since", required = false) Instant since,
                                @RequestParam(value = "limit", defaultValue = "100") @Min(1) int limit) {
        return ReactiveSecurityContextHolder.getContext()
                .map(ctx -> ((BbcmsAuthenticationToken) ctx.getAuthentication()).getUserId())
                .flatMap(userId -> useCase.pullChanges(userId, deviceId, kind, since, limit));
    }
}
