package com.chf.bbcms.authentication.application.port.out;

import com.chf.bbcms.authentication.domain.PasswordResetToken;
import reactor.core.publisher.Mono;

public interface PasswordResetTokenRepository {

    Mono<PasswordResetToken> save(PasswordResetToken token);

    Mono<PasswordResetToken> findByToken(String token);
}
