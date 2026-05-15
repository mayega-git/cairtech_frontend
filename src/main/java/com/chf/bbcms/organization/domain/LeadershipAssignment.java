package com.chf.bbcms.organization.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public class LeadershipAssignment extends BaseEntity {

    private UUID memberId;
    private LeadershipPosition position;
    private UUID scopeBibleClubId;
    private UUID scopeLevelId;
    private LocalDate dateStart;
    private LocalDate dateEnd;
    private boolean active;

    protected LeadershipAssignment() {}

    public static LeadershipAssignment create(UUID memberId, LeadershipPosition position,
                                              UUID scopeBibleClubId, UUID scopeLevelId,
                                              LocalDate dateStart) {
        LeadershipAssignment la = new LeadershipAssignment();
        la.memberId = memberId;
        la.position = position;
        la.scopeBibleClubId = scopeBibleClubId;
        la.scopeLevelId = scopeLevelId;
        la.dateStart = dateStart == null ? LocalDate.now() : dateStart;
        la.active = true;
        return la;
    }

    public static LeadershipAssignment rehydrate(UUID id, UUID memberId, LeadershipPosition position,
                                                 UUID scopeBibleClubId, UUID scopeLevelId,
                                                 LocalDate dateStart, LocalDate dateEnd, boolean active,
                                                 Instant createdAt, Instant updatedAt, Long version) {
        LeadershipAssignment la = new LeadershipAssignment();
        la.id = id;
        la.memberId = memberId;
        la.position = position;
        la.scopeBibleClubId = scopeBibleClubId;
        la.scopeLevelId = scopeLevelId;
        la.dateStart = dateStart;
        la.dateEnd = dateEnd;
        la.active = active;
        la.createdAt = createdAt;
        la.updatedAt = updatedAt;
        la.version = version;
        return la;
    }

    public void revoke(LocalDate when) {
        this.active = false;
        this.dateEnd = when == null ? LocalDate.now() : when;
    }

    public UUID getMemberId() { return memberId; }
    public LeadershipPosition getPosition() { return position; }
    public Optional<UUID> getScopeBibleClubId() { return Optional.ofNullable(scopeBibleClubId); }
    public Optional<UUID> getScopeLevelId() { return Optional.ofNullable(scopeLevelId); }
    public LocalDate getDateStart() { return dateStart; }
    public LocalDate getDateEnd() { return dateEnd; }
    public boolean isActive() { return active; }
}
