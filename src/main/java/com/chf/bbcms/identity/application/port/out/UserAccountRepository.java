package com.chf.bbcms.identity.application.port.out;

import com.chf.bbcms.identity.domain.UserAccount;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface UserAccountRepository {
    Mono<UserAccount> findById(UUID id);
    Mono<UserAccount> findByEmail(String email);
    Mono<Boolean> existsByEmail(String email);
    Mono<UserAccount> save(UserAccount account);
}
