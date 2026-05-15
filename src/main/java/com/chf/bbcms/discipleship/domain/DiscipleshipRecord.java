package com.chf.bbcms.discipleship.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public class DiscipleshipRecord extends BaseEntity {

    private UUID discipleMakerMemberId;
    private UUID meetingId;
    private LocalDate dateOccurred;
    private LocalTime startTime;
    private LocalTime endTime;
    private String theme;
    private String location;
    private String meetingDescription;
    private String disciplesStateText;
    private String spiritualInvestmentText;
    private Set<UUID> presentDiscipleIds = new HashSet<>();

    protected DiscipleshipRecord() {}

    public static DiscipleshipRecord create(UUID maker, UUID meetingId, LocalDate dateOccurred,
                                            LocalTime start, LocalTime end, String theme, String location,
                                            String description, String disciplesState, String investment,
                                            Set<UUID> presentDiscipleIds) {
        if (maker == null) throw new IllegalArgumentException("discipleMakerMemberId required");
        if (dateOccurred == null) throw new IllegalArgumentException("dateOccurred required");
        DiscipleshipRecord r = new DiscipleshipRecord();
        r.discipleMakerMemberId = maker;
        r.meetingId = meetingId;
        r.dateOccurred = dateOccurred;
        r.startTime = start;
        r.endTime = end;
        r.theme = theme;
        r.location = location;
        r.meetingDescription = description;
        r.disciplesStateText = disciplesState;
        r.spiritualInvestmentText = investment;
        r.presentDiscipleIds = presentDiscipleIds == null ? new HashSet<>() : new HashSet<>(presentDiscipleIds);
        return r;
    }

    public static DiscipleshipRecord rehydrate(UUID id, UUID maker, UUID meetingId, LocalDate dateOccurred,
                                               LocalTime start, LocalTime end, String theme, String location,
                                               String description, String disciplesState, String investment,
                                               Set<UUID> presentDiscipleIds, Instant createdAt,
                                               Instant updatedAt, Long version) {
        DiscipleshipRecord r = new DiscipleshipRecord();
        r.id = id;
        r.discipleMakerMemberId = maker;
        r.meetingId = meetingId;
        r.dateOccurred = dateOccurred;
        r.startTime = start;
        r.endTime = end;
        r.theme = theme;
        r.location = location;
        r.meetingDescription = description;
        r.disciplesStateText = disciplesState;
        r.spiritualInvestmentText = investment;
        r.presentDiscipleIds = presentDiscipleIds == null ? new HashSet<>() : new HashSet<>(presentDiscipleIds);
        r.createdAt = createdAt;
        r.updatedAt = updatedAt;
        r.version = version;
        return r;
    }

    public UUID getDiscipleMakerMemberId() { return discipleMakerMemberId; }
    public Optional<UUID> getMeetingId() { return Optional.ofNullable(meetingId); }
    public LocalDate getDateOccurred() { return dateOccurred; }
    public LocalTime getStartTime() { return startTime; }
    public LocalTime getEndTime() { return endTime; }
    public String getTheme() { return theme; }
    public String getLocation() { return location; }
    public String getMeetingDescription() { return meetingDescription; }
    public String getDisciplesStateText() { return disciplesStateText; }
    public String getSpiritualInvestmentText() { return spiritualInvestmentText; }
    public Set<UUID> getPresentDiscipleIds() { return Set.copyOf(presentDiscipleIds); }
}
