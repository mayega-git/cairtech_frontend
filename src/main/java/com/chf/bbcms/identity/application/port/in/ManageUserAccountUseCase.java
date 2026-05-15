package com.chf.bbcms.identity.application.port.in;

import com.chf.bbcms.identity.domain.UserAccount;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ManageUserAccountUseCase {
    Mono<UserAccount> register(RegisterUserCommand command);
    Mono<UserAccount> activateByToken(String activationToken);
    Mono<UserAccount> findById(UUID id);
}
