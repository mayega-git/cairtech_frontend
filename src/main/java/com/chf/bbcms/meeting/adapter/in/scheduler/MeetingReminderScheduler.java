package com.chf.bbcms.meeting.adapter.in.scheduler;

import com.chf.bbcms.meeting.application.port.out.MeetingRepository;
import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingStatus;
import com.chf.bbcms.notification.application.port.out.NotificationPort;
import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.settings.application.port.out.SettingsPort;
import com.chf.bbcms.settings.domain.SettingKeys;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Envoie un rappel email aux membres concernés d'un BBC quand une réunion PLANNED
 * approche (par défaut H-24, paramétrable via meeting.reminder.hours.before).
 * V1: stratégie simple — on rappelle TOUS les membres ACTIFS du BBC. La granularité
 * fine (par level/department) sera affinée en V2 si besoin.
 */
@Component
public class MeetingReminderScheduler {

    private static final Logger log = LoggerFactory.getLogger(MeetingReminderScheduler.class);

    private final MeetingRepository meetingRepository;
    private final MemberRepository memberRepository;
    private final NotificationPort notificationPort;
    private final SettingsPort settings;

    public MeetingReminderScheduler(MeetingRepository meetingRepository,
                                    MemberRepository memberRepository,
                                    NotificationPort notificationPort,
                                    SettingsPort settings) {
        this.meetingRepository = meetingRepository;
        this.memberRepository = memberRepository;
        this.notificationPort = notificationPort;
        this.settings = settings;
    }

    @Scheduled(cron = "0 0 * * * *")
    @SchedulerLock(name = "meeting-reminder", lockAtMostFor = "PT15M", lockAtLeastFor = "PT1M")
    public void sendReminders() {
        settings.getInt(SettingKeys.MEETING_REMINDER_HOURS_BEFORE, 24)
                .flatMapMany(hoursBefore -> meetingRepository.findByStatus(MeetingStatus.PLANNED)
                        .filter(m -> isWithinReminderWindow(m, hoursBefore))
                        .flatMap(this::notifyAttendees))
                .doOnError(ex -> log.error("Meeting reminder sweep failed", ex))
                .subscribe();
    }

    private boolean isWithinReminderWindow(Meeting m, int hoursBefore) {
        if (m.getPlannedDate() == null || m.getPlannedStartTime() == null) return false;
        LocalDateTime plannedAt = LocalDateTime.of(m.getPlannedDate(),
                m.getPlannedStartTime() == null ? LocalTime.MIDNIGHT : m.getPlannedStartTime());
        Duration delta = Duration.between(LocalDateTime.now(), plannedAt);
        long hoursToGo = delta.toHours();
        return hoursToGo == hoursBefore;
    }

    private Mono<Void> notifyAttendees(Meeting m) {
        if (m.getBibleClubId().isEmpty()) return Mono.empty();
        return memberRepository.findByBibleClub(m.getBibleClubId().get())
                .map(member -> member.getUserAccountId())
                .collectList()
                .flatMap(ids -> {
                    NotificationMessage msg = NotificationMessage.email(
                            "Rappel de réunion: " + m.getTitle(),
                            "Vous avez une réunion '%s' planifiée le %s à %s.".formatted(
                                    m.getTitle(), m.getPlannedDate(), m.getPlannedStartTime()));
                    log.info("Sending reminder for meeting {} to {} member(s)", m.getId(), ids.size());
                    return notificationPort.notifyUsers(ids, msg);
                });
    }
}
