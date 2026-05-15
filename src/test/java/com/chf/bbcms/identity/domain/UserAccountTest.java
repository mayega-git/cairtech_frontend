package com.chf.bbcms.identity.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserAccountTest {

    private final UserProfile profile = new UserProfile(
            "Jean", "Dupont", null, Gender.MALE, null, null, null, null);

    @Test
    void register_creates_pending_visitor_with_normalized_email() {
        UserAccount u = UserAccount.register("  Jean@Example.COM ", "hash", "+237600000000",
                profile, "fr");
        assertEquals("jean@example.com", u.getEmail());
        assertEquals(UserStatus.PENDING, u.getStatus());
        assertEquals(UserType.VISITOR, u.getUserType());
    }

    @Test
    void register_rejects_blank_email() {
        assertThrows(IllegalArgumentException.class,
                () -> UserAccount.register("  ", "hash", null, profile, "fr"));
    }

    @Test
    void activate_transitions_pending_to_active() {
        UserAccount u = UserAccount.register("a@b.com", "hash", null, profile, "fr");
        u.activate();
        assertEquals(UserStatus.ACTIVE, u.getStatus());
    }

    @Test
    void activate_rejects_when_not_pending() {
        UserAccount u = UserAccount.register("a@b.com", "hash", null, profile, "fr");
        u.activate();
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, u::activate);
        assertEquals("BBCMS_USER_ALREADY_ACTIVATED", ex.getCode());
    }

    @Test
    void promoteTo_rejects_inactive_account() {
        UserAccount u = UserAccount.register("a@b.com", "hash", null, profile, "fr");
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class,
                () -> u.promoteTo(UserType.STUDENT));
        assertEquals("BBCMS_USER_NOT_ACTIVE", ex.getCode());
    }

    @Test
    void promoteTo_changes_userType_when_active() {
        UserAccount u = UserAccount.register("a@b.com", "hash", null, profile, "fr");
        u.activate();
        u.promoteTo(UserType.STUDENT);
        assertEquals(UserType.STUDENT, u.getUserType());
    }

    @Test
    void anonymize_clears_PII_and_sets_REMOVED() {
        UserAccount u = UserAccount.register("john@example.com", "hash", "+237", profile, "fr");
        u.activate();
        u.anonymize();
        assertEquals(UserStatus.REMOVED, u.getStatus());
        assertEquals("ANONYMIZED", u.getProfile().firstNames());
        assertNull(u.getPhone());
        assertNotNull(u.getAnonymizedAt());
    }
}
