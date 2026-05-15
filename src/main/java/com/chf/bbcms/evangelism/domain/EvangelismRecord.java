package com.chf.bbcms.evangelism.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class EvangelismRecord extends BaseEntity {

    private UUID programId;
    private LocalDate recordDate;
    private int nbPreached;
    private int nbBelieved;
    private int nbEncouraged;
    private int nbTractsShared;
    private String savedContacts;
    private String notes;
    private Set<UUID> participantMemberIds = new HashSet<>();

    protected EvangelismRecord() {}

    public static EvangelismRecord create(UUID programId, LocalDate recordDate,
                                          int preached, int believed, int encouraged,
                                          int tracts, String savedContacts, String notes,
                                          Set<UUID> participantMemberIds) {
        if (programId == null) throw new IllegalArgumentException("programId required");
        if (recordDate == null) throw new IllegalArgumentException("recordDate required");
        if (preached < 0 || believed < 0 || encouraged < 0 || tracts < 0)
            throw new IllegalArgumentException("counters must be >= 0");
        EvangelismRecord r = new EvangelismRecord();
        r.programId = programId;
        r.recordDate = recordDate;
        r.nbPreached = preached;
        r.nbBelieved = believed;
        r.nbEncouraged = encouraged;
        r.nbTractsShared = tracts;
        r.savedContacts = savedContacts;
        r.notes = notes;
        r.participantMemberIds = participantMemberIds == null ? new HashSet<>()
                : new HashSet<>(participantMemberIds);
        return r;
    }

    public static EvangelismRecord rehydrate(UUID id, UUID programId, LocalDate recordDate,
                                             int preached, int believed, int encouraged, int tracts,
                                             String savedContacts, String notes,
                                             Set<UUID> participantMemberIds,
                                             Instant createdAt, Instant updatedAt, Long version) {
        EvangelismRecord r = new EvangelismRecord();
        r.id = id;
        r.programId = programId;
        r.recordDate = recordDate;
        r.nbPreached = preached;
        r.nbBelieved = believed;
        r.nbEncouraged = encouraged;
        r.nbTractsShared = tracts;
        r.savedContacts = savedContacts;
        r.notes = notes;
        r.participantMemberIds = participantMemberIds == null ? new HashSet<>()
                : new HashSet<>(participantMemberIds);
        r.createdAt = createdAt;
        r.updatedAt = updatedAt;
        r.version = version;
        return r;
    }

    public UUID getProgramId() { return programId; }
    public LocalDate getRecordDate() { return recordDate; }
    public int getNbPreached() { return nbPreached; }
    public int getNbBelieved() { return nbBelieved; }
    public int getNbEncouraged() { return nbEncouraged; }
    public int getNbTractsShared() { return nbTractsShared; }
    public String getSavedContacts() { return savedContacts; }
    public String getNotes() { return notes; }
    public Set<UUID> getParticipantMemberIds() { return Set.copyOf(participantMemberIds); }
}
