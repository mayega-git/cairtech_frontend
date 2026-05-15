package com.chf.bbcms.meeting.application.port.out;

import com.chf.bbcms.meeting.domain.Meeting;
import com.chf.bbcms.meeting.domain.MeetingPicture;
import com.chf.bbcms.meeting.domain.MeetingPresence;
import com.chf.bbcms.meeting.domain.MeetingStatus;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface MeetingRepository {
    Mono<Meeting> findById(UUID id);
    Flux<Meeting> findByBibleClub(UUID bibleClubId);
    Flux<Meeting> findByStatus(MeetingStatus status);
    Flux<Meeting> findRecordedSince(LocalDate since);
    Mono<Meeting> save(Meeting meeting);

    Flux<MeetingPresence> findPresences(UUID meetingId);
    Mono<Void> savePresences(UUID meetingId, List<MeetingPresence> presences);
    Mono<Long> countPicturesByMeeting(UUID meetingId);
    Mono<Void> savePictures(UUID meetingId, List<MeetingPicture> pictures);

    /** Compte les meetings RECORDED qui auraient concerné ce membre dans l'année académique. */
    Mono<Long> countEligibleForMember(UUID memberId, UUID bibleClubId, UUID levelId,
                                      Iterable<String> departments, int academicYear);
}
