package com.chf.bbcms.reset.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Table("bbcms_bbc_reset_snapshot")
public class ResetSnapshotRow {
    @Id private UUID id;
    @Column("bible_club_id") private UUID bibleClubId;
    @Column("academic_year") private int academicYear;
    @Column("nb_members_before") private int nbMembersBefore;
    @Column("nb_faithful_before") private int nbFaithfulBefore;
    @Column("nb_meetings") private int nbMeetings;
    @Column("percentage_reached") private BigDecimal percentageReached;
    @Column("archived_at") private Instant archivedAt;
    @Column("archive_file_id") private UUID archiveFileId;
    @Column("created_by") private UUID createdBy;

    public UUID getId() { return id; } public void setId(UUID id) { this.id = id; }
    public UUID getBibleClubId() { return bibleClubId; } public void setBibleClubId(UUID b) { this.bibleClubId = b; }
    public int getAcademicYear() { return academicYear; } public void setAcademicYear(int y) { this.academicYear = y; }
    public int getNbMembersBefore() { return nbMembersBefore; } public void setNbMembersBefore(int n) { this.nbMembersBefore = n; }
    public int getNbFaithfulBefore() { return nbFaithfulBefore; } public void setNbFaithfulBefore(int n) { this.nbFaithfulBefore = n; }
    public int getNbMeetings() { return nbMeetings; } public void setNbMeetings(int n) { this.nbMeetings = n; }
    public BigDecimal getPercentageReached() { return percentageReached; } public void setPercentageReached(BigDecimal p) { this.percentageReached = p; }
    public Instant getArchivedAt() { return archivedAt; } public void setArchivedAt(Instant a) { this.archivedAt = a; }
    public UUID getArchiveFileId() { return archiveFileId; } public void setArchiveFileId(UUID a) { this.archiveFileId = a; }
    public UUID getCreatedBy() { return createdBy; } public void setCreatedBy(UUID c) { this.createdBy = c; }
}
