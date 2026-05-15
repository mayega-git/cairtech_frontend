package com.chf.bbcms.evangelism.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class EvangelismProgram extends BaseEntity {

    private String title;
    private EvangelismProgramType type;
    private int objectiveBelievers;
    private int totalPreached;
    private int totalSaved;
    private int totalEncouraged;
    private EvangelismProgramStatus status;
    private Set<LocalDate> dates = new HashSet<>();
    private Set<UUID> bibleClubIds = new HashSet<>();

    protected EvangelismProgram() {}

    public static EvangelismProgram draft(String title, EvangelismProgramType type, int objectiveBelievers) {
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (type == null) throw new IllegalArgumentException("type required");
        if (objectiveBelievers < 0) throw new IllegalArgumentException("objectiveBelievers >= 0");
        EvangelismProgram p = new EvangelismProgram();
        p.title = title;
        p.type = type;
        p.objectiveBelievers = objectiveBelievers;
        p.status = EvangelismProgramStatus.DRAFT;
        return p;
    }

    public static EvangelismProgram rehydrate(UUID id, String title, EvangelismProgramType type,
                                              int objectiveBelievers, int totalPreached, int totalSaved,
                                              int totalEncouraged, EvangelismProgramStatus status,
                                              Set<LocalDate> dates, Set<UUID> bibleClubIds,
                                              Instant createdAt, Instant updatedAt, Long version) {
        EvangelismProgram p = new EvangelismProgram();
        p.id = id;
        p.title = title;
        p.type = type;
        p.objectiveBelievers = objectiveBelievers;
        p.totalPreached = totalPreached;
        p.totalSaved = totalSaved;
        p.totalEncouraged = totalEncouraged;
        p.status = status;
        p.dates = dates == null ? new HashSet<>() : new HashSet<>(dates);
        p.bibleClubIds = bibleClubIds == null ? new HashSet<>() : new HashSet<>(bibleClubIds);
        p.createdAt = createdAt;
        p.updatedAt = updatedAt;
        p.version = version;
        return p;
    }

    public void addDate(LocalDate date) {
        ensureNotClosed();
        if (date == null) throw new IllegalArgumentException("date required");
        dates.add(date);
    }

    public void addBibleClub(UUID bibleClubId) {
        ensureNotClosed();
        if (bibleClubId == null) throw new IllegalArgumentException("bibleClubId required");
        bibleClubIds.add(bibleClubId);
    }

    public void activate() {
        if (status != EvangelismProgramStatus.DRAFT)
            throw new BusinessRuleViolation("BBCMS_EVG_BAD_STATE", "Only DRAFT programs can be activated");
        if (dates.isEmpty())
            throw new BusinessRuleViolation("BBCMS_EVG_NO_DATES", "Program must have at least one date");
        this.status = EvangelismProgramStatus.ACTIVE;
    }

    public void close() {
        if (status == EvangelismProgramStatus.CLOSED)
            throw new BusinessRuleViolation("BBCMS_EVG_TERMINAL", "Program already CLOSED");
        this.status = EvangelismProgramStatus.CLOSED;
    }

    /** RM-06: la date d'un EvangelismRecord doit ∈ dates du programme. */
    public void validateRecordDate(LocalDate date) {
        if (!dates.contains(date))
            throw new BusinessRuleViolation("BBCMS_EVG_RECORD_DATE_OUT_OF_PROGRAM",
                    "Record date %s is not in program dates".formatted(date));
    }

    public void aggregate(int preached, int believed, int encouraged) {
        if (status != EvangelismProgramStatus.ACTIVE)
            throw new BusinessRuleViolation("BBCMS_EVG_NOT_ACTIVE",
                    "Cannot aggregate on a non-ACTIVE program");
        this.totalPreached += preached;
        this.totalSaved += believed;
        this.totalEncouraged += encouraged;
    }

    private void ensureNotClosed() {
        if (status == EvangelismProgramStatus.CLOSED)
            throw new BusinessRuleViolation("BBCMS_EVG_TERMINAL", "Cannot mutate a CLOSED program");
    }

    public String getTitle() { return title; }
    public EvangelismProgramType getType() { return type; }
    public int getObjectiveBelievers() { return objectiveBelievers; }
    public int getTotalPreached() { return totalPreached; }
    public int getTotalSaved() { return totalSaved; }
    public int getTotalEncouraged() { return totalEncouraged; }
    public EvangelismProgramStatus getStatus() { return status; }
    public Set<LocalDate> getDates() { return Set.copyOf(dates); }
    public Set<UUID> getBibleClubIds() { return Set.copyOf(bibleClubIds); }
    public double percentageReached() {
        return objectiveBelievers == 0 ? 0d : (totalSaved * 100d / objectiveBelievers);
    }
}
