package com.chf.bbcms.discipleship.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.LocalDate;
import java.util.UUID;

public class DiscipleLink {

    private UUID id;
    private UUID discipleMakerMemberId;
    private UUID discipleMemberId;
    private LocalDate dateAssigned;
    private LocalDate dateEnded;
    private boolean active;

    protected DiscipleLink() {}

    public static DiscipleLink assign(UUID maker, UUID disciple) {
        if (maker == null || disciple == null)
            throw new IllegalArgumentException("maker and disciple required");
        if (maker.equals(disciple))
            throw new BusinessRuleViolation("BBCMS_DISCIPLE_SELF",
                    "A member cannot be their own disciple maker");
        DiscipleLink l = new DiscipleLink();
        l.discipleMakerMemberId = maker;
        l.discipleMemberId = disciple;
        l.dateAssigned = LocalDate.now();
        l.active = true;
        return l;
    }

    public static DiscipleLink rehydrate(UUID id, UUID maker, UUID disciple,
                                         LocalDate assigned, LocalDate ended, boolean active) {
        DiscipleLink l = new DiscipleLink();
        l.id = id;
        l.discipleMakerMemberId = maker;
        l.discipleMemberId = disciple;
        l.dateAssigned = assigned;
        l.dateEnded = ended;
        l.active = active;
        return l;
    }

    public void end(LocalDate when) {
        this.active = false;
        this.dateEnded = when == null ? LocalDate.now() : when;
    }

    public UUID getId() { return id; }
    public UUID getDiscipleMakerMemberId() { return discipleMakerMemberId; }
    public UUID getDiscipleMemberId() { return discipleMemberId; }
    public LocalDate getDateAssigned() { return dateAssigned; }
    public LocalDate getDateEnded() { return dateEnded; }
    public boolean isActive() { return active; }
}
