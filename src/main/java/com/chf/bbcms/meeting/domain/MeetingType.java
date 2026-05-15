package com.chf.bbcms.meeting.domain;

public enum MeetingType {
    CLASS_MEETING,
    JOINT_CLASS_MEETING,
    JOINT_BBC_MEETING,
    DEPARTMENTAL_MEETING,
    LEADERS_MEETING,
    GENERAL_MEETING,
    /** Ne compte PAS dans la fidélité étudiante (table 4.3 du Cahier). */
    ACADEMIC_MEETING,
    SPIRITUAL_RETREAT,
    PRAYER_MEETING,
    WELCOME_PARTY,
    CONFERENCE,
    FEAST;

    /** True si la présence à ce type de réunion contribue au score de fidélité. */
    public boolean countsForFaithfulness() {
        return this != ACADEMIC_MEETING;
    }
}
