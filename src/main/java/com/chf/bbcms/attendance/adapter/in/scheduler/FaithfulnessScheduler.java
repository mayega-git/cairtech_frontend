package com.chf.bbcms.attendance.adapter.in.scheduler;

import com.chf.bbcms.attendance.application.port.in.AttendanceUseCase;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Recalcule la fidélité de tous les étudiants actifs chaque jour à 02h00.
 * Verrou ShedLock pour garantir un seul exécutant par cluster.
 */
@Component
public class FaithfulnessScheduler {

    private static final Logger log = LoggerFactory.getLogger(FaithfulnessScheduler.class);

    private final AttendanceUseCase attendance;

    public FaithfulnessScheduler(AttendanceUseCase attendance) {
        this.attendance = attendance;
    }

    @Scheduled(cron = "${bbcms.faithfulness.cron:0 0 2 * * *}")
    @SchedulerLock(name = "faithfulness-recompute", lockAtMostFor = "PT30M", lockAtLeastFor = "PT1M")
    public void recompute() {
        log.info("Triggering daily faithfulness recompute");
        attendance.recomputeAllFaithfulness()
                .doOnError(ex -> log.error("Faithfulness recompute failed", ex))
                .subscribe();
    }
}
