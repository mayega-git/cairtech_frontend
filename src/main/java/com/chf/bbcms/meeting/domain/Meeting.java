package com.chf.bbcms.meeting.domain;

import com.chf.bbcms.people.domain.Department;
import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * Agrégat Meeting avec state machine PLANNED → ONGOING → ENDED → RECORDED (terminal),
 * ou CANCELLED depuis PLANNED/ENDED.
 */
public class Meeting extends BaseEntity {

    private UUID bibleClubId;
    private UUID levelId;
    private Department department;
    private Set<UUID> levelsConcerned = new HashSet<>();
    private Set<UUID> bibleClubsConcerned = new HashSet<>();
    private String title;
    private MeetingType type;
    private LocalDate plannedDate;
    private LocalTime plannedStartTime;
    private LocalTime plannedEndTime;
    private LocalDate dateOccurred;
    private LocalTime startTime;
    private LocalTime endTime;
    private Integer durationMinutes;
    private UUID teacherMemberId;
    private String summary;
    private int nbBelievers;
    private int maxPictures;
    private MeetingStatus status;

    protected Meeting() {}

    public static Meeting plan(String title, MeetingType type, UUID bibleClubId, UUID levelId,
                               LocalDate plannedDate, LocalTime plannedStartTime,
                               LocalTime plannedEndTime, int maxPictures) {
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (type == null) throw new IllegalArgumentException("type required");
        if (plannedDate == null || plannedStartTime == null)
            throw new IllegalArgumentException("plannedDate and plannedStartTime required");
        Meeting m = new Meeting();
        m.title = title;
        m.type = type;
        m.bibleClubId = bibleClubId;
        m.levelId = levelId;
        m.plannedDate = plannedDate;
        m.plannedStartTime = plannedStartTime;
        m.plannedEndTime = plannedEndTime;
        m.maxPictures = maxPictures > 0 ? maxPictures : 20;
        m.status = MeetingStatus.PLANNED;
        return m;
    }

    public static Meeting rehydrate(UUID id, UUID bibleClubId, UUID levelId, Department department,
                                    Set<UUID> levelsConcerned, Set<UUID> bibleClubsConcerned,
                                    String title, MeetingType type,
                                    LocalDate plannedDate, LocalTime plannedStartTime, LocalTime plannedEndTime,
                                    LocalDate dateOccurred, LocalTime startTime, LocalTime endTime,
                                    Integer durationMinutes, UUID teacherMemberId, String summary,
                                    int nbBelievers, int maxPictures, MeetingStatus status,
                                    Instant createdAt, Instant updatedAt, Long version) {
        Meeting m = new Meeting();
        m.id = id;
        m.bibleClubId = bibleClubId;
        m.levelId = levelId;
        m.department = department;
        m.levelsConcerned = levelsConcerned == null ? new HashSet<>() : new HashSet<>(levelsConcerned);
        m.bibleClubsConcerned = bibleClubsConcerned == null ? new HashSet<>() : new HashSet<>(bibleClubsConcerned);
        m.title = title;
        m.type = type;
        m.plannedDate = plannedDate;
        m.plannedStartTime = plannedStartTime;
        m.plannedEndTime = plannedEndTime;
        m.dateOccurred = dateOccurred;
        m.startTime = startTime;
        m.endTime = endTime;
        m.durationMinutes = durationMinutes;
        m.teacherMemberId = teacherMemberId;
        m.summary = summary;
        m.nbBelievers = nbBelievers;
        m.maxPictures = maxPictures;
        m.status = status;
        m.createdAt = createdAt;
        m.updatedAt = updatedAt;
        m.version = version;
        return m;
    }

    public void start(LocalDate dateOccurred, LocalTime startTime) {
        ensureStatus(MeetingStatus.PLANNED, "BBCMS_MEETING_NOT_PLANNED",
                "Meeting must be PLANNED to start");
        this.dateOccurred = dateOccurred == null ? LocalDate.now() : dateOccurred;
        this.startTime = startTime == null ? LocalTime.now() : startTime;
        this.status = MeetingStatus.ONGOING;
    }

    public void end(LocalTime endTime) {
        ensureStatus(MeetingStatus.ONGOING, "BBCMS_MEETING_NOT_ONGOING",
                "Meeting must be ONGOING to end");
        this.endTime = endTime == null ? LocalTime.now() : endTime;
        if (startTime != null && this.endTime != null) {
            this.durationMinutes = (int) Duration.between(startTime, this.endTime).toMinutes();
        }
        this.status = MeetingStatus.ENDED;
    }

    /**
     * Transition unique de PLANNED|ONGOING|ENDED → RECORDED. Applique nbBelievers + summary.
     * Une fois RECORDED, l'agrégat est immuable (RM-05).
     */
    public void record(LocalDate dateOccurred, LocalTime startTime, LocalTime endTime,
                       int nbBelievers, String summary, int actualPictureCount) {
        if (status == MeetingStatus.RECORDED || status == MeetingStatus.CANCELLED)
            throw new BusinessRuleViolation("BBCMS_MEETING_TERMINAL",
                    "Meeting cannot be recorded from " + status);
        if (actualPictureCount > maxPictures)
            throw new BusinessRuleViolation("BBCMS_MEETING_MAX_PICTURES",
                    "Picture count %d exceeds max %d (RM-04)".formatted(actualPictureCount, maxPictures));
        if (nbBelievers < 0) throw new IllegalArgumentException("nbBelievers must be >= 0");
        if (this.dateOccurred == null) this.dateOccurred = dateOccurred == null ? LocalDate.now() : dateOccurred;
        if (this.startTime == null && startTime != null) this.startTime = startTime;
        if (endTime != null) this.endTime = endTime;
        if (this.startTime != null && this.endTime != null) {
            this.durationMinutes = (int) Duration.between(this.startTime, this.endTime).toMinutes();
        }
        this.nbBelievers = nbBelievers;
        this.summary = summary;
        this.status = MeetingStatus.RECORDED;
    }

    public void cancel() {
        if (status == MeetingStatus.RECORDED)
            throw new BusinessRuleViolation("BBCMS_MEETING_TERMINAL", "RECORDED meeting cannot be cancelled");
        this.status = MeetingStatus.CANCELLED;
    }

    public void setTeacher(UUID teacherMemberId) {
        ensureMutable();
        this.teacherMemberId = teacherMemberId;
    }

    public void setDepartment(Department dep) { ensureMutable(); this.department = dep; }

    public void addLevelConcerned(UUID levelId) { ensureMutable(); levelsConcerned.add(levelId); }
    public void addBibleClubConcerned(UUID bbcId) { ensureMutable(); bibleClubsConcerned.add(bbcId); }

    private void ensureStatus(MeetingStatus expected, String code, String msg) {
        if (status != expected) throw new BusinessRuleViolation(code, msg + " (current=" + status + ")");
    }

    private void ensureMutable() {
        if (status == MeetingStatus.RECORDED || status == MeetingStatus.CANCELLED)
            throw new BusinessRuleViolation("BBCMS_MEETING_TERMINAL",
                    "Cannot mutate a " + status + " meeting");
    }

    public Optional<UUID> getBibleClubId() { return Optional.ofNullable(bibleClubId); }
    public Optional<UUID> getLevelId() { return Optional.ofNullable(levelId); }
    public Optional<Department> getDepartment() { return Optional.ofNullable(department); }
    public Set<UUID> getLevelsConcerned() { return Set.copyOf(levelsConcerned); }
    public Set<UUID> getBibleClubsConcerned() { return Set.copyOf(bibleClubsConcerned); }
    public String getTitle() { return title; }
    public MeetingType getType() { return type; }
    public LocalDate getPlannedDate() { return plannedDate; }
    public LocalTime getPlannedStartTime() { return plannedStartTime; }
    public LocalTime getPlannedEndTime() { return plannedEndTime; }
    public LocalDate getDateOccurred() { return dateOccurred; }
    public LocalTime getStartTime() { return startTime; }
    public LocalTime getEndTime() { return endTime; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public Optional<UUID> getTeacherMemberId() { return Optional.ofNullable(teacherMemberId); }
    public String getSummary() { return summary; }
    public int getNbBelievers() { return nbBelievers; }
    public int getMaxPictures() { return maxPictures; }
    public MeetingStatus getStatus() { return status; }
    public boolean isJoint() {
        return type == MeetingType.JOINT_BBC_MEETING || type == MeetingType.JOINT_CLASS_MEETING;
    }
}
