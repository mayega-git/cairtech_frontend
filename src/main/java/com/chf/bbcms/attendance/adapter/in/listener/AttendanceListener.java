package com.chf.bbcms.attendance.adapter.in.listener;

import com.chf.bbcms.attendance.application.port.in.AttendanceUseCase;
import com.chf.bbcms.attendance.domain.FaithfulnessSource;
import com.chf.bbcms.shared.outbox.OutboxRepublished;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Consomme les événements republiés depuis l'outbox pour incrémenter les scores
 * de fidélité. Idempotent grâce à AttendanceScoreRepository.tryAddRecord (ON CONFLICT DO NOTHING).
 */
@Component
public class AttendanceListener {

    private static final Logger log = LoggerFactory.getLogger(AttendanceListener.class);

    private final AttendanceUseCase attendance;
    private final ObjectMapper objectMapper;

    public AttendanceListener(AttendanceUseCase attendance, ObjectMapper objectMapper) {
        this.attendance = attendance;
        this.objectMapper = objectMapper;
    }

    @EventListener
    public void onOutboxRepublished(OutboxRepublished event) {
        try {
            switch (event.type()) {
                case "MEETING_RECORDED" -> handleMeetingRecorded(event);
                case "EVENT_ATTENDED" -> handleEventAttended(event);
                case "EVANGELISM_RECORDED" -> handleEvangelismRecorded(event);
                default -> { /* ignore */ }
            }
        } catch (Exception ex) {
            log.error("Failed to handle outbox event {}: {}", event.type(), ex.getMessage(), ex);
        }
    }

    private void handleMeetingRecorded(OutboxRepublished event) throws Exception {
        JsonNode payload = objectMapper.readTree(event.payloadJson());
        UUID meetingId = UUID.fromString(payload.get("meetingId").asText());
        String meetingType = payload.get("meetingType").asText();
        // ACADEMIC_MEETING ne compte pas (table 4.3 du Cahier).
        if ("ACADEMIC_MEETING".equals(meetingType)) return;
        JsonNode members = payload.get("presentMemberIds");
        if (members == null || !members.isArray()) return;
        for (JsonNode m : members) {
            UUID memberId = UUID.fromString(m.asText());
            attendance.recordPresence(memberId, FaithfulnessSource.MEETING, meetingId, null, null)
                    .doOnError(ex -> log.warn("recordPresence MEETING failed for member {}: {}",
                            memberId, ex.getMessage()))
                    .onErrorResume(ex -> reactor.core.publisher.Mono.empty())
                    .subscribe();
        }
    }

    private void handleEventAttended(OutboxRepublished event) throws Exception {
        JsonNode payload = objectMapper.readTree(event.payloadJson());
        UUID eventId = UUID.fromString(payload.get("eventId").asText());
        UUID memberId = UUID.fromString(payload.get("memberId").asText());
        attendance.recordPresence(memberId, FaithfulnessSource.EVENT, null, eventId, null)
                .doOnError(ex -> log.warn("recordPresence EVENT failed for member {}: {}",
                        memberId, ex.getMessage()))
                .onErrorResume(ex -> reactor.core.publisher.Mono.empty())
                .subscribe();
    }

    private void handleEvangelismRecorded(OutboxRepublished event) throws Exception {
        JsonNode payload = objectMapper.readTree(event.payloadJson());
        UUID recordId = UUID.fromString(payload.get("evangelismRecordId").asText());
        JsonNode members = payload.get("participantMemberIds");
        if (members == null || !members.isArray()) return;
        for (JsonNode m : members) {
            UUID memberId = UUID.fromString(m.asText());
            attendance.recordPresence(memberId, FaithfulnessSource.EVANGELISM, null, null, recordId)
                    .onErrorResume(ex -> reactor.core.publisher.Mono.empty())
                    .subscribe();
        }
    }
}
