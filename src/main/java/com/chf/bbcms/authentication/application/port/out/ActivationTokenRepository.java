package com.chf.bbcms.authentication.application.port.out;

import com.chf.bbcms.authentication.domain.ActivationToken;
import reactor.core.publisher.Mono;

public interface ActivationTokenRepository {
    Mono<ActivationToken> save(ActivationToken token);
    Mono<ActivationToken> findByToken(String token);
}
