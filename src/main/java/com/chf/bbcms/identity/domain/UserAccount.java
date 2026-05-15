package com.chf.bbcms.identity.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.util.UUID;

/**
 * Agrégat racine: compte utilisateur. Porte les PII (UserProfile en composition).
 */
public class UserAccount extends BaseEntity {

    private String email;
    private String passwordHash;
    private String phone;
    private UserStatus status;
    private UserType userType;
    private Instant lastLoginAt;
    private String locale;
    private UserProfile profile;
    private Instant anonymizedAt;

    protected UserAccount() {}

    public static UserAccount register(String email, String passwordHash, String phone,
                                       UserProfile profile, String locale) {
        UserAccount u = new UserAccount();
        u.email = normalizeEmail(email);
        u.passwordHash = passwordHash;
        u.phone = phone;
        u.profile = profile;
        u.status = UserStatus.PENDING;
        u.userType = UserType.VISITOR;
        u.locale = locale == null ? "fr" : locale;
        return u;
    }

    public static UserAccount rehydrate(UUID id, String email, String passwordHash, String phone,
                                        UserStatus status, UserType userType, Instant lastLoginAt,
                                        String locale, UserProfile profile, Instant anonymizedAt,
                                        Instant createdAt, Instant updatedAt, Long version) {
        UserAccount u = new UserAccount();
        u.id = id;
        u.email = email;
        u.passwordHash = passwordHash;
        u.phone = phone;
        u.status = status;
        u.userType = userType;
        u.lastLoginAt = lastLoginAt;
        u.locale = locale;
        u.profile = profile;
        u.anonymizedAt = anonymizedAt;
        u.createdAt = createdAt;
        u.updatedAt = updatedAt;
        u.version = version;
        return u;
    }

    public void activate() {
        if (status != UserStatus.PENDING) {
            throw new BusinessRuleViolation("BBCMS_USER_ALREADY_ACTIVATED",
                    "User account is not in PENDING state (current=%s)".formatted(status));
        }
        this.status = UserStatus.ACTIVE;
    }

    public void promoteTo(UserType type) {
        if (status != UserStatus.ACTIVE) {
            throw new BusinessRuleViolation("BBCMS_USER_NOT_ACTIVE",
                    "Cannot change user_type if account is not ACTIVE");
        }
        this.userType = type;
    }

    public void recordLogin(Instant when) { this.lastLoginAt = when; }

    public void changePasswordHash(String newHash) { this.passwordHash = newHash; }

    public void anonymize() {
        String anonId = id != null ? id.toString() : java.util.UUID.randomUUID().toString();
        this.email = anonId + "@anonymized.bbcms";
        this.phone = null;
        this.profile = new UserProfile("ANONYMIZED", null, null, profile.gender(),
                null, null, null, null);
        this.anonymizedAt = Instant.now();
        this.status = UserStatus.REMOVED;
    }

    private static String normalizeEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("email is required");
        }
        return email.trim().toLowerCase();
    }

    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public String getPhone() { return phone; }
    public UserStatus getStatus() { return status; }
    public UserType getUserType() { return userType; }
    public Instant getLastLoginAt() { return lastLoginAt; }
    public String getLocale() { return locale; }
    public UserProfile getProfile() { return profile; }
    public Instant getAnonymizedAt() { return anonymizedAt; }
}
