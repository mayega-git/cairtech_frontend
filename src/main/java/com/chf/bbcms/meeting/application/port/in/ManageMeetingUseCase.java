package com.chf.bbcms.meeting.application.port.in;

import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingType;
import com.chf.bbcms.meeting.domain.PresenceRole;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public interface ManageMeetingUseCase {

    Mono<Meeting> plan(PlanMeetingCommand cmd);
    Mono<Meeting> start(UUID meetingId, LocalDate dateOccurred, LocalTime startTime);
    Mono<Meeting> end(UUID meetingId, LocalTime endTime);
    Mono<Meeting> record(RecordMeetingCommand cmd);
    Mono<Meeting> cancel(UUID meetingId);
    Mono<Meeting> findById(UUID meetingId);
    Flux<Meeting> listByBibleClub(UUID bibleClubId);

    record PlanMeetingCommand(
            String title, MeetingType type,
            UUID bibleClubId, UUID levelId,
            LocalDate plannedDate, LocalTime plannedStartTime, LocalTime plannedEndTime,
            UUID teacherMemberId, Integer maxPictures
    ) {}

    record RecordMeetingCommand(
            UUID meetingId,
            LocalDate dateOccurred, LocalTime startTime, LocalTime endTime,
            int nbBelievers, String summary,
            List<PresenceItem> presents,
            List<PictureItem> pictures
    ) {}

    record PresenceItem(UUID memberId, UUID visitorId, PresenceRole role) {}
    record PictureItem(UUID fileId, String caption) {}
}
