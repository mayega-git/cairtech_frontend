package com.chf.bbcms.authentication.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

public class ActivationToken {

    private static final SecureRandom RNG = new SecureRandom();

    private UUID id;
    private UUID userAccountId;
    private String token;
    private Instant expiresAt;
    private boolean used;

    protected ActivationToken() {}

    public static ActivationToken issue(UUID userAccountId, java.time.Duration ttl) {
        ActivationToken t = new ActivationToken();
        t.userAccountId = userAccountId;
        t.token = generateToken();
        t.expiresAt = Instant.now().plus(ttl);
        t.used = false;
        return t;
    }

    public static ActivationToken rehydrate(UUID id, UUID userAccountId, String token,
                                            Instant expiresAt, boolean used) {
        ActivationToken t = new ActivationToken();
        t.id = id;
        t.userAccountId = userAccountId;
        t.token = token;
        t.expiresAt = expiresAt;
        t.used = used;
        return t;
    }

    public void consume() {
        if (used) {
            throw new BusinessRuleViolation("BBCMS_TOKEN_ALREADY_USED", "Activation token already used");
        }
        if (Instant.now().isAfter(expiresAt)) {
            throw new BusinessRuleViolation("BBCMS_TOKEN_EXPIRED", "Activation token expired");
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
