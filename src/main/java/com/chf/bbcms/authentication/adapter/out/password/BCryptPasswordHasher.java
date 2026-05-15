package com.chf.bbcms.authentication.adapter.out.password;

import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

/**
 * BCrypt est CPU-bound bloquant: on déporte sur boundedElastic
 * pour ne pas bloquer la boucle event-loop WebFlux.
 */
@Component
public class BCryptPasswordHasher implements PasswordHasher {

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);

    @Override
    public Mono<String> hash(String plain) {
        return Mono.fromCallable(() -> encoder.encode(plain))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @Override
    public Mono<Boolean> matches(String plain, String hash) {
        return Mono.fromCallable(() -> encoder.matches(plain, hash))
                .subscribeOn(Schedulers.boundedElastic());
    }
}
