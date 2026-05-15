package com.chf.bbcms.meeting.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

/**
 * Présence d'un membre OU d'un visiteur à une réunion (XOR appliqué côté DB par CHECK).
 */
public class MeetingPresence {

    private UUID id;
    private UUID meetingId;
    private UUID memberId;
    private UUID visitorId;
    private Instant presentAt;
    private PresenceRole role;

    protected MeetingPresence() {}

    public static MeetingPresence ofMember(UUID meetingId, UUID memberId, PresenceRole role) {
        if (memberId == null) throw new IllegalArgumentException("memberId required");
        return create(meetingId, memberId, null, role);
    }

    public static MeetingPresence ofVisitor(UUID meetingId, UUID visitorId, PresenceRole role) {
        if (visitorId == null) throw new IllegalArgumentException("visitorId required");
        return create(meetingId, null, visitorId, role == null ? PresenceRole.VISITOR : role);
    }

    public static MeetingPresence rehydrate(UUID id, UUID meetingId, UUID memberId, UUID visitorId,
                                            Instant presentAt, PresenceRole role) {
        MeetingPresence p = new MeetingPresence();
        p.id = id;
        p.meetingId = meetingId;
        p.memberId = memberId;
        p.visitorId = visitorId;
        p.presentAt = presentAt;
        p.role = role;
        return p;
    }

    private static MeetingPresence create(UUID meetingId, UUID memberId, UUID visitorId,
                                          PresenceRole role) {
        if (meetingId == null) throw new IllegalArgumentException("meetingId required");
        if (memberId != null && visitorId != null)
            throw new BusinessRuleViolation("BBCMS_PRESENCE_BOTH_LINKS",
                    "Presence cannot have both memberId and visitorId");
        MeetingPresence p = new MeetingPresence();
        p.meetingId = meetingId;
        p.memberId = memberId;
        p.visitorId = visitorId;
        p.presentAt = Instant.now();
        p.role = role == null ? (memberId != null ? PresenceRole.MEMBER : PresenceRole.VISITOR) : role;
        return p;
    }

    public UUID getId() { return id; }
    public UUID getMeetingId() { return meetingId; }
    public Optional<UUID> getMemberId() { return Optional.ofNullable(memberId); }
    public Optional<UUID> getVisitorId() { return Optional.ofNullable(visitorId); }
    public Instant getPresentAt() { return presentAt; }
    public PresenceRole getRole() { return role; }
    public boolean isMember() { return memberId != null; }
}
