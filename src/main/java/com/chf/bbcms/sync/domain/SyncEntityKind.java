package com.chf.bbcms.sync.domain;

/**
 * Catalogue des entités synchronisables avec un client offline.
 * Chaque kind correspond à une table avec une colonne updated_at.
 */
public enum SyncEntityKind {
    BIBLE_CLUB("bbcms_bible_club"),
    LEVEL("bbcms_level"),
    MEMBER("bbcms_member"),
    MEETING("bbcms_meeting"),
    EVENT("bbcms_event"),
    ATTENDANCE_SCORE("bbcms_attendance_score"),
    DAILY_VERSE_PUBLICATION("bbcms_daily_verse_publication"),
    SPECIAL_ANNOUNCEMENT("bbcms_special_announcement");

    private final String tableName;

    SyncEntityKind(String tableName) {
        this.tableName = tableName;
    }

    public String tableName() { return tableName; }
}
