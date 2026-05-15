package com.chf.bbcms.sync.domain;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class SyncCursorTest {

    @Test
    void initial_cursor_starts_at_epoch() {
        SyncCursor c = SyncCursor.initial(UUID.randomUUID(), "device-1", SyncEntityKind.MEETING);
        assertEquals(Instant.EPOCH, c.lastSyncedAt());
        assertEquals(SyncEntityKind.MEETING, c.entityKind());
    }

    @Test
    void advance_keeps_identity_fields() {
        UUID userId = UUID.randomUUID();
        SyncCursor original = SyncCursor.initial(userId, "device-1", SyncEntityKind.MEMBER);
        Instant to = Instant.parse("2025-10-15T08:00:00Z");
        SyncCursor advanced = original.advance(to);
        assertEquals(to, advanced.lastSyncedAt());
        assertEquals(userId, advanced.userAccountId());
        assertEquals("device-1", advanced.deviceId());
        assertEquals(SyncEntityKind.MEMBER, advanced.entityKind());
    }
}
