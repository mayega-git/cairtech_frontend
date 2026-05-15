package com.chf.bbcms.authentication.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class ActivationTokenTest {

    @Test
    void issue_generates_unique_tokens() {
        UUID userId = UUID.randomUUID();
        ActivationToken a = ActivationToken.issue(userId, Duration.ofDays(7));
        ActivationToken b = ActivationToken.issue(userId, Duration.ofDays(7));
        assertNotEquals(a.getToken(), b.getToken());
        assertFalse(a.isUsed());
        assertEquals(userId, a.getUserAccountId());
    }

    @Test
    void consume_rejects_already_used_token() {
        ActivationToken t = ActivationToken.issue(UUID.randomUUID(), Duration.ofDays(7));
        t.consume();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, t::consume);
        assertEquals("BBCMS_TOKEN_ALREADY_USED", ex.getCode());
    }

    @Test
    void consume_rejects_expired_token() {
        ActivationToken t = ActivationToken.issue(UUID.randomUUID(), Duration.ofMillis(-1));
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, t::consume);
        assertEquals("BBCMS_TOKEN_EXPIRED", ex.getCode());
    }
}
