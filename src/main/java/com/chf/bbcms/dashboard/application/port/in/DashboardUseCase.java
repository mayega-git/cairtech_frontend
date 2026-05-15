package com.chf.bbcms.dashboard.application.port.in;

import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface DashboardUseCase {

    Mono<BibleClubDashboard> bibleClubDashboard(UUID bibleClubId, int academicYear);

    Mono<NationalDashboard> nationalDashboard(int academicYear);

    record BibleClubDashboard(
            UUID bibleClubId,
            String name,
            String status,
            int academicYear,
            Integer goalNbFaithful,
            long nbMembers,
            long nbFaithful,
            BigDecimal percentageReached,
            long nbMeetingsRecorded,
            long nbActiveContributions,
            BigDecimal totalContributedAmount
    ) {}

    record NationalDashboard(
            int academicYear,
            long nbBibleClubs,
            long nbMembersTotal,
            long nbFaithfulTotal,
            long nbMeetingsRecordedTotal,
            BigDecimal totalContributedTotal,
            List<BibleClubDashboard> perBibleClub
    ) {}
}
