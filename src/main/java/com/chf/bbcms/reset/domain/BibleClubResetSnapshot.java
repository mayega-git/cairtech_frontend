package com.chf.bbcms.reset.domain;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.UUID;

/**
 * Snapshot annuel d'un Bible Club lors de son reset.
 * Capturé avant transferts/réinit des scores. archive_file_id pointe vers un PDF
 * archive stocké dans MinIO (bucket bbcms-media).
 */
public record BibleClubResetSnapshot(
        UUID id,
        UUID bibleClubId,
        int academicYear,
        int nbMembersBefore,
        int nbFaithfulBefore,
        int nbMeetings,
        BigDecimal percentageReached,
        Instant archivedAt,
        UUID archiveFileId,
        UUID createdBy
) {
    public static BibleClubResetSnapshot capture(UUID bibleClubId, int year, int nbMembers,
                                                 int nbFaithful, int nbMeetings, Integer goal,
                                                 UUID createdBy) {
        BigDecimal pct = BigDecimal.ZERO;
        if (goal != null && goal > 0) {
            pct = BigDecimal.valueOf(nbFaithful)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(goal), 2, RoundingMode.HALF_UP);
        }
        return new BibleClubResetSnapshot(null, bibleClubId, year, nbMembers, nbFaithful,
                nbMeetings, pct, Instant.now(), null, createdBy);
    }

    public BibleClubResetSnapshot withArchiveFileId(UUID fileId) {
        return new BibleClubResetSnapshot(id, bibleClubId, academicYear, nbMembersBefore,
                nbFaithfulBefore, nbMeetings, percentageReached, archivedAt, fileId, createdBy);
    }
}
