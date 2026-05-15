package com.chf.bbcms.sync.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class SyncEntityKindTest {

    @Test
    void each_kind_maps_to_a_table() {
        for (SyncEntityKind k : SyncEntityKind.values()) {
            assertNotNull(k.tableName());
            assertTrue(k.tableName().startsWith("bbcms_"),
                    "table for " + k + " should be prefixed bbcms_");
        }
    }

    @Test
    void meeting_kind_targets_meeting_table() {
        assertEquals("bbcms_meeting", SyncEntityKind.MEETING.tableName());
    }
}
