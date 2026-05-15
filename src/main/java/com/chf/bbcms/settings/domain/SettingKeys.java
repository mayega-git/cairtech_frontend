package com.chf.bbcms.settings.domain;

/**
 * Catalogue des clés de paramètres système, alignées avec 18-seed-settings.xml.
 */
public final class SettingKeys {

    public static final String FAITHFULNESS_THRESHOLD_PCT       = "faithfulness.threshold.percentage";
    public static final String FAITHFULNESS_MEETING_WEIGHT      = "faithfulness.meeting.weight";
    public static final String FAITHFULNESS_EVENT_WEIGHT        = "faithfulness.event.weight";
    public static final String FAITHFULNESS_EVANGELISM_WEIGHT   = "faithfulness.evangelism.weight";
    public static final String FAITHFULNESS_CRON                = "faithfulness.cron";
    public static final String INACTIVITY_WARNING_DAYS          = "inactivity.warning.threshold.days";
    public static final String INACTIVITY_REMOVAL_DAYS          = "inactivity.removal.threshold.days";
    public static final String MEETING_MAX_PICTURES_DEFAULT     = "meeting.max.pictures.default";
    public static final String MEETING_REMINDER_HOURS_BEFORE    = "meeting.reminder.hours.before";
    public static final String RGPD_ANONYMIZATION_DELAY_MONTHS  = "rgpd.anonymization.delay.months";
    public static final String FINANCE_DEFAULT_CURRENCY         = "finance.default.currency";

    private SettingKeys() {}
}
