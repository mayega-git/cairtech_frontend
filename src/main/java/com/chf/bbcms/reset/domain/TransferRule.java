package com.chf.bbcms.reset.domain;

import com.chf.bbcms.organization.domain.LevelType;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Règle de transfert annuel: L1→L2, L2→L3, ..., L6→L7, L7→TRANSFERRED (gradué).
 * Configurable mais V1 utilise le mapping standard.
 */
public final class TransferRule {

    private static final Map<LevelType, LevelType> NEXT = new HashMap<>();
    static {
        NEXT.put(LevelType.L1, LevelType.L2);
        NEXT.put(LevelType.L2, LevelType.L3);
        NEXT.put(LevelType.L3, LevelType.L4);
        NEXT.put(LevelType.L4, LevelType.L5);
        NEXT.put(LevelType.L5, LevelType.L6);
        NEXT.put(LevelType.L6, LevelType.L7);
        // L7 → null (graduated, member status TRANSFERRED)
    }

    private TransferRule() {}

    public static Optional<LevelType> nextLevelFor(LevelType current) {
        return Optional.ofNullable(NEXT.get(current));
    }

    public static boolean isGraduating(LevelType current) {
        return current == LevelType.L7;
    }
}
