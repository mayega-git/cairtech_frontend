package com.chf.bbcms.authentication.application.port.in;

import reactor.core.publisher.Mono;

public interface AuthenticationUseCase {

    Mono<TokenPair> login(String email, String plainPassword);
    Mono<TokenPair> refresh(String refreshToken);
    Mono<Void> logout(String refreshToken);

    record TokenPair(String accessToken, String refreshToken, long accessTokenExpiresInSeconds) {}
}
