package com.chf.bbcms.evangelism.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_evangelism_record")
public class EvangelismRecordRow {
    @Id private UUID id;
    @Column("program_id") private UUID programId;
    @Column("record_date") private LocalDate recordDate;
    @Column("nb_preached") private int nbPreached;
    @Column("nb_believed") private int nbBelieved;
    @Column("nb_encouraged") private int nbEncouraged;
    @Column("nb_tracts_shared") private int nbTractsShared;
    @Column("saved_contacts") private String savedContacts;
    private String notes;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getProgramId() { return programId; } public void setProgramId(UUID p) { this.programId = p; }
    public LocalDate getRecordDate() { return recordDate; } public void setRecordDate(LocalDate r) { this.recordDate = r; }
    public int getNbPreached() { return nbPreached; } public void setNbPreached(int n) { this.nbPreached = n; }
    public int getNbBelieved() { return nbBelieved; } public void setNbBelieved(int n) { this.nbBelieved = n; }
    public int getNbEncouraged() { return nbEncouraged; } public void setNbEncouraged(int n) { this.nbEncouraged = n; }
    public int getNbTractsShared() { return nbTractsShared; } public void setNbTractsShared(int n) { this.nbTractsShared = n; }
    public String getSavedContacts() { return savedContacts; } public void setSavedContacts(String s) { this.savedContacts = s; }
    public String getNotes() { return notes; } public void setNotes(String n) { this.notes = n; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; } public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; } public void setVersion(Long v) { this.version = v; }
}
