package com.chf.bbcms.event.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

public class Event extends BaseEntity {

    private String title;
    private EventType type;
    private Instant plannedStartDt;
    private Instant plannedEndDt;
    private Instant startedAt;
    private Instant endedAt;
    private Integer durationMinutes;
    private String location;
    private int maxPictures;
    private EventStatus status;
    private UUID imageFileId;

    protected Event() {}

    public static Event plan(String title, EventType type, Instant plannedStartDt,
                             Instant plannedEndDt, String location, int maxPictures,
                             UUID imageFileId) {
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title required");
        if (type == null) throw new IllegalArgumentException("type required");
        if (plannedStartDt == null) throw new IllegalArgumentException("plannedStartDt required");
        Event e = new Event();
        e.title = title;
        e.type = type;
        e.plannedStartDt = plannedStartDt;
        e.plannedEndDt = plannedEndDt;
        e.location = location;
        e.maxPictures = maxPictures > 0 ? maxPictures : 50;
        e.status = EventStatus.PLANNED;
        e.imageFileId = imageFileId;
        return e;
    }

    public static Event rehydrate(UUID id, String title, EventType type,
                                  Instant plannedStartDt, Instant plannedEndDt,
                                  Instant startedAt, Instant endedAt, Integer durationMinutes,
                                  String location, int maxPictures, EventStatus status,
                                  UUID imageFileId,
                                  Instant createdAt, Instant updatedAt, Long version) {
        Event e = new Event();
        e.id = id;
        e.title = title;
        e.type = type;
        e.plannedStartDt = plannedStartDt;
        e.plannedEndDt = plannedEndDt;
        e.startedAt = startedAt;
        e.endedAt = endedAt;
        e.durationMinutes = durationMinutes;
        e.location = location;
        e.maxPictures = maxPictures;
        e.status = status;
        e.imageFileId = imageFileId;
        e.createdAt = createdAt;
        e.updatedAt = updatedAt;
        e.version = version;
        return e;
    }

    public void setImageFileId(UUID imageFileId) { this.imageFileId = imageFileId; }

    public void openRegistration() {
        if (status != EventStatus.PLANNED)
            throw new BusinessRuleViolation("BBCMS_EVENT_BAD_STATE",
                    "Registration can only open from PLANNED");
        this.status = EventStatus.REGISTRATION_OPEN;
    }

    public void start(Instant when) {
        if (status != EventStatus.PLANNED && status != EventStatus.REGISTRATION_OPEN)
            throw new BusinessRuleViolation("BBCMS_EVENT_BAD_STATE", "Cannot start from " + status);
        this.startedAt = when == null ? Instant.now() : when;
        this.status = EventStatus.ONGOING;
    }

    public void end(Instant when) {
        if (status != EventStatus.ONGOING)
            throw new BusinessRuleViolation("BBCMS_EVENT_BAD_STATE", "Event is not ONGOING");
        this.endedAt = when == null ? Instant.now() : when;
        if (startedAt != null) {
            this.durationMinutes = (int) Duration.between(startedAt, this.endedAt).toMinutes();
        }
        this.status = EventStatus.ENDED;
    }

    public void cancel() {
        if (status == EventStatus.ENDED)
            throw new BusinessRuleViolation("BBCMS_EVENT_TERMINAL", "ENDED event cannot be cancelled");
        this.status = EventStatus.CANCELLED;
    }

    public boolean acceptsEnrollment() {
        return status == EventStatus.PLANNED || status == EventStatus.REGISTRATION_OPEN;
    }

    public String getTitle() { return title; }
    public EventType getType() { return type; }
    public Instant getPlannedStartDt() { return plannedStartDt; }
    public Instant getPlannedEndDt() { return plannedEndDt; }
    public Instant getStartedAt() { return startedAt; }
    public Instant getEndedAt() { return endedAt; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public String getLocation() { return location; }
    public int getMaxPictures() { return maxPictures; }
    public EventStatus getStatus() { return status; }
    public UUID getImageFileId() { return imageFileId; }
}
