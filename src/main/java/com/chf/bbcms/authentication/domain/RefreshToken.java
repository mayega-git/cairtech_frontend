package com.chf.bbcms.authentication.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

public class RefreshToken {

    private static final SecureRandom RNG = new SecureRandom();

    private UUID id;
    private UUID userAccountId;
    private String tokenHash;
    private Instant expiresAt;
    private boolean revoked;
    private Instant createdAt;

    /** Le clear-text token n'est pas persisté: on garde son hash. */
    private transient String clearText;

    protected RefreshToken() {}

    public static RefreshToken issue(UUID userAccountId, Duration ttl) {
        RefreshToken t = new RefreshToken();
        t.userAccountId = userAccountId;
        t.clearText = generateClearText();
        t.tokenHash = sha256(t.clearText);
        t.expiresAt = Instant.now().plus(ttl);
        t.revoked = false;
        t.createdAt = Instant.now();
        return t;
    }

    public static RefreshToken rehydrate(UUID id, UUID userAccountId, String tokenHash,
                                         Instant expiresAt, boolean revoked, Instant createdAt) {
        RefreshToken t = new RefreshToken();
        t.id = id;
        t.userAccountId = userAccountId;
        t.tokenHash = tokenHash;
        t.expiresAt = expiresAt;
        t.revoked = revoked;
        t.createdAt = createdAt;
        return t;
    }

    public void revoke() { this.revoked = true; }

    public void ensureUsable() {
        if (revoked) throw new BusinessRuleViolation("BBCMS_REFRESH_REVOKED", "Refresh token revoked");
        if (Instant.now().isAfter(expiresAt))
            throw new BusinessRuleViolation("BBCMS_REFRESH_EXPIRED", "Refresh token expired");
    }

    public static String hashFor(String clearText) { return sha256(clearText); }

    private static String generateClearText() {
        byte[] bytes = new byte[64];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(input.getBytes()));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    public UUID getId() { return id; }
    public UUID getUserAccountId() { return userAccountId; }
    public String getTokenHash() { return tokenHash; }
    public Instant getExpiresAt() { return expiresAt; }
    public boolean isRevoked() { return revoked; }
    public Instant getCreatedAt() { return createdAt; }
    public String getClearText() { return clearText; }
}
