package com.chf.bbcms.authentication.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

/**
 * Token à usage unique pour le flux de réinitialisation de mot de passe.
 *
 * Émis à la demande d'un utilisateur via /auth/reset-password ; envoyé par email
 * sous forme de lien `/reset-password?token=...`. La consommation transforme
 * `used=false → true` et exige une expiration non dépassée.
 */
public class PasswordResetToken {

    private static final SecureRandom RNG = new SecureRandom();

    private UUID id;
    private UUID userAccountId;
    private String token;
    private Instant expiresAt;
    private boolean used;

    protected PasswordResetToken() {}

    public static PasswordResetToken issue(UUID userAccountId, Duration ttl) {
        PasswordResetToken t = new PasswordResetToken();
        t.userAccountId = userAccountId;
        t.token = generateToken();
        t.expiresAt = Instant.now().plus(ttl);
        t.used = false;
        return t;
    }

    public static PasswordResetToken rehydrate(UUID id, UUID userAccountId, String token,
                                               Instant expiresAt, boolean used) {
        PasswordResetToken t = new PasswordResetToken();
        t.id = id;
        t.userAccountId = userAccountId;
        t.token = token;
        t.expiresAt = expiresAt;
        t.used = used;
        return t;
    }

    public void consume() {
        if (used) {
            throw new BusinessRuleViolation("BBCMS_TOKEN_ALREADY_USED",
                    "Password reset token already used");
        }
        if (Instant.now().isAfter(expiresAt)) {
            throw new BusinessRuleViolation("BBCMS_TOKEN_EXPIRED",
                    "Password reset token expired");
        }
        this.used = true;
    }

    private static String generateToken() {
        byte[] bytes = new byte[48];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public UUID getId() { return id; }
    public UUID getUserAccountId() { return userAccountId; }
    public String getToken() { return token; }
    public Instant getExpiresAt() { return expiresAt; }
    public boolean isUsed() { return used; }
}
