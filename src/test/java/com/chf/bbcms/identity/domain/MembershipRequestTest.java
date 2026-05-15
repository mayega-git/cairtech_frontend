package com.chf.bbcms.identity.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class MembershipRequestTest {

    @Test
    void student_request_requires_bbc_and_level() {
        UUID u = UUID.randomUUID();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> MembershipRequest.submit(u, UserType.STUDENT, null, null, null));
        assertEquals("BBCMS_REQUEST_INCOMPLETE", ex.getCode());
    }

    @Test
    void professional_request_requires_profession() {
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> MembershipRequest.submit(UUID.randomUUID(), UserType.PROFESSIONAL,
                        null, null, " "));
        assertEquals("BBCMS_REQUEST_INCOMPLETE", ex.getCode());
    }

    @Test
    void visitor_type_rejected() {
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> MembershipRequest.submit(UUID.randomUUID(), UserType.VISITOR,
                        null, null, null));
        assertEquals("BBCMS_REQUEST_INVALID_TYPE", ex.getCode());
    }

    @Test
    void approve_transitions_to_approved_and_records_decision() {
        MembershipRequest r = MembershipRequest.submit(UUID.randomUUID(), UserType.STUDENT,
                UUID.randomUUID(), UUID.randomUUID(), null);
        UUID approver = UUID.randomUUID();
        r.approve(approver, null, null, "OK");
        assertEquals(MembershipRequestStatus.APPROVED, r.getStatus());
        assertEquals(approver, r.getDecisionBy());
        assertEquals("OK", r.getDecisionComment());
        assertNotNull(r.getDecisionAt());
    }

    @Test
    void cannot_approve_twice() {
        MembershipRequest r = MembershipRequest.submit(UUID.randomUUID(), UserType.STUDENT,
                UUID.randomUUID(), UUID.randomUUID(), null);
        r.approve(UUID.randomUUID(), null, null, null);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> r.approve(UUID.randomUUID(), null, null, null));
        assertEquals("BBCMS_REQUEST_NOT_PENDING", ex.getCode());
    }

    @Test
    void approve_can_override_assigned_bbc_and_level() {
        UUID originalBbc = UUID.randomUUID();
        UUID originalLevel = UUID.randomUUID();
        MembershipRequest r = MembershipRequest.submit(UUID.randomUUID(), UserType.STUDENT,
                originalBbc, originalLevel, null);
        UUID newBbc = UUID.randomUUID();
        UUID newLevel = UUID.randomUUID();
        r.approve(UUID.randomUUID(), newBbc, newLevel, null);
        assertEquals(newBbc, r.getBibleClubId().orElseThrow());
        assertEquals(newLevel, r.getLevelId().orElseThrow());
    }
}
