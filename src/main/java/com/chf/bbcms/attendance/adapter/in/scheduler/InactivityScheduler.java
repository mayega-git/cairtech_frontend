package com.chf.bbcms.attendance.adapter.in.scheduler;

import com.chf.bbcms.attendance.application.port.out.InactivityWatchRepository;
import com.chf.bbcms.people.application.port.in.ManageMemberUseCase;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.people.domain.MemberStatus;
import com.chf.bbcms.settings.application.port.out.SettingsPort;
import com.chf.bbcms.settings.domain.SettingKeys;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

/**
 * Applique les transitions d'inactivité quotidiennement à 03h00:
 *  - lastSeenAt > warningDays (30j par défaut)  → status = INACTIVE
 *  - lastSeenAt > removalDays (90j par défaut)  → status = REMOVED + markRemoved
 */
@Component
public class InactivityScheduler {

    private static final Logger log = LoggerFactory.getLogger(InactivityScheduler.class);

    private final InactivityWatchRepository watchRepository;
    private final MemberRepository memberRepository;
    private final ManageMemberUseCase memberUseCase;
    private final SettingsPort settings;

    public InactivityScheduler(InactivityWatchRepository watchRepository,
                               MemberRepository memberRepository,
                               ManageMemberUseCase memberUseCase,
                               SettingsPort settings) {
        this.watchRepository = watchRepository;
        this.memberRepository = memberRepository;
        this.memberUseCase = memberUseCase;
        this.settings = settings;
    }

    @Scheduled(cron = "0 0 3 * * *")
    @SchedulerLock(name = "inactivity-sweep", lockAtMostFor = "PT15M", lockAtLeastFor = "PT30S")
    public void sweep() {
        Instant now = Instant.now();
        Mono<Integer> warningDays = settings.getInt(SettingKeys.INACTIVITY_WARNING_DAYS, 30);
        Mono<Integer> removalDays = settings.getInt(SettingKeys.INACTIVITY_REMOVAL_DAYS, 90);

        Mono.zip(warningDays, removalDays)
                .flatMapMany(tuple -> watchRepository.findActive()
                        .flatMap(watch -> processWatch(watch, now, tuple.getT1(), tuple.getT2())))
                .doOnError(ex -> log.error("Inactivity sweep failed", ex))
                .subscribe(n -> log.debug("Inactivity processed for member {}", n));
    }

    private Flux<Object> processWatch(com.chf.bbcms.attendance.domain.InactivityWatch watch,
                                      Instant now, int warningDays, int removalDays) {
        if (watch.shouldBeRemoved(now) || watch.getThresholdDays() <= removalDays
                && watch.getLastSeenAt() != null
                && java.time.Duration.between(watch.getLastSeenAt(), now).toDays() > removalDays) {
            return memberRepository.findById(watch.getMemberId()).flatMapMany(member -> {
                member.leave(); // → REMOVED
                watch.markRemoved(now);
                return memberRepository.save(member)
                        .then(watchRepository.save(watch))
                        .doOnSuccess(x -> log.info("Member {} REMOVED for inactivity > {}d",
                                member.getId(), removalDays))
                        .flatMapMany(x -> Flux.empty());
            });
        }
        if (watch.shouldBeMarkedInactive(now, warningDays)) {
            return memberRepository.findById(watch.getMemberId()).flatMapMany(member -> {
                if (member.getStatus() == MemberStatus.ACTIVE) {
                    member.markInactive();
                    return memberRepository.save(member).flatMapMany(x -> Flux.empty());
                }
                return Flux.empty();
            });
        }
        return Flux.empty();
    }
}
