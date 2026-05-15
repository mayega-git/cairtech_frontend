package com.chf.bbcms.authentication.application.port.out;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public interface JwtIssuer {

    String issueAccessToken(JwtClaims claims);
    JwtClaims parseAndValidate(String token);

    record JwtClaims(
            UUID userId,
            String email,
            String userType,
            Set<String> roles,
            Set<String> permissions,
            UUID bibleClubId,
            Instant issuedAt,
            Instant expiresAt
    ) {}
}
