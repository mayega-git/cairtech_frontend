package com.chf.bbcms.dashboard.application.service;

import com.chf.bbcms.attendance.application.port.out.AttendanceScoreRepository;
import com.chf.bbcms.dashboard.application.port.in.DashboardUseCase;
import com.chf.bbcms.finance.application.port.out.FinancialContributionRepository;
import com.chf.bbcms.finance.domain.ContributionStatus;
import com.chf.bbcms.meeting.application.port.out.MeetingRepository;
import com.chf.bbcms.meeting.domain.MeetingStatus;
import com.chf.bbcms.organization.application.port.out.BibleClubRepository;
import com.chf.bbcms.organization.domain.BibleClub;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.MemberKind;
import com.chf.bbcms.people.domain.MemberStatus;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Service
public class DashboardService implements DashboardUseCase {

    private final BibleClubRepository bibleClubRepository;
    private final MemberRepository memberRepository;
    private final AttendanceScoreRepository scoreRepository;
    private final FinancialContributionRepository financeRepository;
    private final MeetingRepository meetingRepository;

    public DashboardService(BibleClubRepository bibleClubRepository,
                            MemberRepository memberRepository,
                            AttendanceScoreRepository scoreRepository,
                            FinancialContributionRepository financeRepository,
                            MeetingRepository meetingRepository) {
        this.bibleClubRepository = bibleClubRepository;
        this.memberRepository = memberRepository;
        this.scoreRepository = scoreRepository;
        this.financeRepository = financeRepository;
        this.meetingRepository = meetingRepository;
    }

    @Override
    public Mono<BibleClubDashboard> bibleClubDashboard(UUID bibleClubId, int academicYear) {
        return bibleClubRepository.findById(bibleClubId)
                .switchIfEmpty(Mono.error(new NotFoundException("BibleClub", bibleClubId)))
                .flatMap(bbc -> buildDashboard(bbc, academicYear));
    }

    @Override
    public Mono<NationalDashboard> nationalDashboard(int academicYear) {
        return bibleClubRepository.findAll()
                .flatMap(bbc -> buildDashboard(bbc, academicYear))
                .collectList()
                .map(perBbc -> {
                    long members = perBbc.stream().mapToLong(BibleClubDashboard::nbMembers).sum();
                    long faithful = perBbc.stream().mapToLong(BibleClubDashboard::nbFaithful).sum();
                    long meetings = perBbc.stream().mapToLong(BibleClubDashboard::nbMeetingsRecorded).sum();
                    BigDecimal totalContrib = perBbc.stream()
                            .map(BibleClubDashboard::totalContributedAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                    return new NationalDashboard(academicYear, perBbc.size(),
                            members, faithful, meetings, totalContrib, perBbc);
                });
    }

    private Mono<BibleClubDashboard> buildDashboard(BibleClub bbc, int academicYear) {
        Mono<Long> nbMembers = memberRepository.findByBibleClub(bbc.getId())
                .filter(m -> m.getKind() == MemberKind.STUDENT && m.getStatus() == MemberStatus.ACTIVE)
                .count();
        Mono<Long> nbFaithful = scoreRepository.findByBibleClubAndYear(bbc.getId(), academicYear)
                .filter(s -> s.isFaithful())
                .count();
        Mono<List<com.chf.bbcms.finance.domain.FinancialContribution>> contribs =
                financeRepository.findByBibleClub(bbc.getId()).collectList();
        Mono<Long> nbRecorded = meetingRepository.findByBibleClub(bbc.getId())
                .filter(meeting -> meeting.getStatus() == MeetingStatus.RECORDED)
                .count();

        return Mono.zip(nbMembers, nbFaithful, contribs, nbRecorded).map(t -> {
            long m = t.getT1();
            long f = t.getT2();
            long active = t.getT3().stream().filter(c -> c.getStatus() == ContributionStatus.OPEN).count();
            BigDecimal total = t.getT3().stream()
                    .map(c -> c.getTotalContributed())
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal pct = computePercentage(f, bbc.getGoalNbFaithful());
            return new BibleClubDashboard(bbc.getId(), bbc.getName(), bbc.getStatus().name(),
                    academicYear, bbc.getGoalNbFaithful(), m, f, pct, t.getT4(), active, total);
        });
    }

    private BigDecimal computePercentage(long faithful, Integer goal) {
        if (goal == null || goal == 0) return BigDecimal.ZERO;
        return BigDecimal.valueOf(faithful).multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(goal), 2, RoundingMode.HALF_UP);
    }
}
