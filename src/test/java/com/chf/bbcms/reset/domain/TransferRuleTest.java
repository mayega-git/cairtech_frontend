package com.chf.bbcms.reset.domain;

import com.chf.bbcms.organization.domain.LevelType;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class TransferRuleTest {

    @Test
    void L1_to_L6_transfer_to_next() {
        assertEquals(LevelType.L2, TransferRule.nextLevelFor(LevelType.L1).orElseThrow());
        assertEquals(LevelType.L3, TransferRule.nextLevelFor(LevelType.L2).orElseThrow());
        assertEquals(LevelType.L4, TransferRule.nextLevelFor(LevelType.L3).orElseThrow());
        assertEquals(LevelType.L5, TransferRule.nextLevelFor(LevelType.L4).orElseThrow());
        assertEquals(LevelType.L6, TransferRule.nextLevelFor(LevelType.L5).orElseThrow());
        assertEquals(LevelType.L7, TransferRule.nextLevelFor(LevelType.L6).orElseThrow());
    }

    @Test
    void L7_has_no_next_and_is_graduating() {
        assertTrue(TransferRule.nextLevelFor(LevelType.L7).isEmpty());
        assertTrue(TransferRule.isGraduating(LevelType.L7));
    }

    @Test
    void L1_is_not_graduating() {
        assertFalse(TransferRule.isGraduating(LevelType.L1));
    }
}
