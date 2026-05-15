package com.chf.bbcms.authentication.application.port.out;

import reactor.core.publisher.Mono;

public interface PasswordHasher {
    Mono<String> hash(String plain);
    Mono<Boolean> matches(String plain, String hash);
}
