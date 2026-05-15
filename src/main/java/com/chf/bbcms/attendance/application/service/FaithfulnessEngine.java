package com.chf.bbcms.attendance.application.service;

import com.chf.bbcms.attendance.domain.AttendanceScore;
import com.chf.bbcms.attendance.domain.FaithfulnessSource;
import com.chf.bbcms.settings.application.port.out.SettingsPort;
import com.chf.bbcms.settings.domain.SettingKeys;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;

/**
 * Cœur du calcul de fidélité (RM-01, RM-02). Stateless.
 * Lit les seuils via SettingsPort (cache Caffeine).
 */
@Component
public class FaithfulnessEngine {

    private static final BigDecimal DEFAULT_THRESHOLD = BigDecimal.valueOf(50);

    private final SettingsPort settings;

    public FaithfulnessEngine(SettingsPort settings) {
        this.settings = settings;
    }

    /** Récupère le poids configuré pour une source donnée (par défaut 1). */
    public Mono<Integer> weightFor(FaithfulnessSource source) {
        return switch (source) {
            case MEETING -> settings.getInt(SettingKeys.FAITHFULNESS_MEETING_WEIGHT, 1);
            case EVENT -> settings.getInt(SettingKeys.FAITHFULNESS_EVENT_WEIGHT, 1);
            case EVANGELISM -> settings.getInt(SettingKeys.FAITHFULNESS_EVANGELISM_WEIGHT, 1);
        };
    }

    public Mono<BigDecimal> threshold() {
        return settings.getDecimal(SettingKeys.FAITHFULNESS_THRESHOLD_PCT, DEFAULT_THRESHOLD);
    }

    /**
     * Recalcule un AttendanceScore avec un nouveau total éligible.
     * P% = score / totalEligible × 100, faithful = P% >= seuil.
     */
    public Mono<AttendanceScore> recompute(AttendanceScore score, int totalEligible) {
        return threshold().map(th -> { score.recompute(totalEligible, th); return score; });
    }
}
