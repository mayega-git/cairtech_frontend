package com.chf.bbcms.authentication.adapter.out.jwt;

import com.chf.bbcms.authentication.application.port.out.JwtIssuer;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Component
public class JjwtIssuer implements JwtIssuer {

    private final SecretKey signingKey;
    private final String issuer;
    private final Duration accessTtl;

    public JjwtIssuer(@Value("${bbcms.security.jwt.secret}") String secret,
                      @Value("${bbcms.security.jwt.issuer}") String issuer,
                      @Value("${bbcms.security.jwt.access-token-ttl}") Duration accessTtl) {
        if (secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException("bbcms.security.jwt.secret must be at least 256 bits (32 bytes)");
        }
        this.signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.issuer = issuer;
        this.accessTtl = accessTtl;
    }

    @Override
    public String issueAccessToken(JwtClaims claims) {
        Instant now = Instant.now();
        return Jwts.builder()
                .issuer(issuer)
                .subject(claims.userId().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(accessTtl)))
                .claim("email", claims.email())
                .claim("userType", claims.userType())
                .claim("roles", claims.roles())
                .claim("permissions", claims.permissions())
                .claim("bibleClubId", claims.bibleClubId() == null ? null : claims.bibleClubId().toString())
                .signWith(signingKey)
                .compact();
    }

    @Override
    public JwtClaims parseAndValidate(String token) {
        try {
            Claims c = Jwts.parser().verifyWith(signingKey).build()
                    .parseSignedClaims(token).getPayload();
            String bbcId = c.get("bibleClubId", String.class);
            return new JwtClaims(
                    UUID.fromString(c.getSubject()),
                    c.get("email", String.class),
                    c.get("userType", String.class),
                    toSet(c.get("roles", List.class)),
                    toSet(c.get("permissions", List.class)),
                    bbcId == null ? null : UUID.fromString(bbcId),
                    c.getIssuedAt().toInstant(),
                    c.getExpiration().toInstant()
            );
        } catch (JwtException e) {
            throw new BusinessRuleViolation("BBCMS_INVALID_TOKEN", "Invalid or expired JWT");
        }
    }

    @SuppressWarnings("unchecked")
    private static Set<String> toSet(List<?> raw) {
        if (raw == null) return Set.of();
        return new HashSet<>((List<String>) raw);
    }
}
