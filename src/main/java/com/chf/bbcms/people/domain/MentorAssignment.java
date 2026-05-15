package com.chf.bbcms.people.domain;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Lien Mentor ↔ BibleClub. Pas d'identifiant propre — clé composite (memberId, bibleClubId).
 */
public record MentorAssignment(
        UUID memberId,
        UUID bibleClubId,
        LocalDate dateStart,
        LocalDate dateEnd
) {
    public MentorAssignment {
        if (memberId == null) throw new IllegalArgumentException("memberId is required");
        if (bibleClubId == null) throw new IllegalArgumentException("bibleClubId is required");
        if (dateStart == null) dateStart = LocalDate.now();
    }

    public boolean isActive() {
        return dateEnd == null || dateEnd.isAfter(LocalDate.now());
    }
}
