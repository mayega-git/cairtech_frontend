package com.chf.bbcms.authentication.application.port.out;

import com.chf.bbcms.authentication.domain.RefreshToken;
import reactor.core.publisher.Mono;

public interface RefreshTokenRepository {
    Mono<RefreshToken> save(RefreshToken token);
    Mono<RefreshToken> findByHash(String tokenHash);
}
