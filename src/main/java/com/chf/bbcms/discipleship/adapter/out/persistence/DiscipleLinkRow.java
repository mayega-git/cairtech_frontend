package com.chf.bbcms.discipleship.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_disciple_link")
public class DiscipleLinkRow {
    @Id private UUID id;
    @Column("disciple_maker_member_id") private UUID discipleMakerMemberId;
    @Column("disciple_member_id") private UUID discipleMemberId;
    @Column("date_assigned") private LocalDate dateAssigned;
    @Column("date_ended") private LocalDate dateEnded;
    private boolean active;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getDiscipleMakerMemberId() { return discipleMakerMemberId; } public void setDiscipleMakerMemberId(UUID m) { this.discipleMakerMemberId = m; }
    public UUID getDiscipleMemberId() { return discipleMemberId; } public void setDiscipleMemberId(UUID d) { this.discipleMemberId = d; }
    public LocalDate getDateAssigned() { return dateAssigned; } public void setDateAssigned(LocalDate d) { this.dateAssigned = d; }
    public LocalDate getDateEnded() { return dateEnded; } public void setDateEnded(LocalDate d) { this.dateEnded = d; }
    public boolean isActive() { return active; } public void setActive(boolean a) { this.active = a; }
}
