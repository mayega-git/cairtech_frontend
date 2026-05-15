package com.chf.bbcms.reset.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class BibleClubResetSnapshotTest {

    @Test
    void capture_computes_percentage_against_goal() {
        BibleClubResetSnapshot s = BibleClubResetSnapshot.capture(UUID.randomUUID(), 2025,
                30, 18, 24, 30, UUID.randomUUID());
        assertEquals(0, s.percentageReached().compareTo(BigDecimal.valueOf(60.00).setScale(2)));
        assertEquals(30, s.nbMembersBefore());
        assertEquals(18, s.nbFaithfulBefore());
    }

    @Test
    void capture_zero_goal_returns_zero_percentage() {
        BibleClubResetSnapshot s = BibleClubResetSnapshot.capture(UUID.randomUUID(), 2025,
                10, 5, 0, null, UUID.randomUUID());
        assertEquals(0, s.percentageReached().compareTo(BigDecimal.ZERO));
    }

    @Test
    void withArchiveFileId_keeps_other_fields() {
        BibleClubResetSnapshot s = BibleClubResetSnapshot.capture(UUID.randomUUID(), 2025,
                10, 5, 12, 10, UUID.randomUUID());
        UUID fileId = UUID.randomUUID();
        BibleClubResetSnapshot updated = s.withArchiveFileId(fileId);
        assertEquals(fileId, updated.archiveFileId());
        assertEquals(s.bibleClubId(), updated.bibleClubId());
        assertEquals(s.percentageReached(), updated.percentageReached());
    }
}
