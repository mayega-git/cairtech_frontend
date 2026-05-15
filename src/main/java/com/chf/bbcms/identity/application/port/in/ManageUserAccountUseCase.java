package com.chf.bbcms.identity.application.port.in;

import com.chf.bbcms.identity.domain.UserAccount;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface ManageUserAccountUseCase {
    Mono<UserAccount> register(RegisterUserCommand command);
    Mono<UserAccount> activateByToken(String activationToken);
    Mono<UserAccount> findById(UUID id);

    /** Démarre un flux de reset — silencieux si l'email n'existe pas (anti-enumeration). */
    Mono<Void> requestPasswordReset(String email);

    /** Consomme un PasswordResetToken et applique le nouveau mot de passe. */
    Mono<Void> confirmPasswordReset(String token, String newPassword);

    /** Change le mot de passe de l'utilisateur connecté (vérification de l'ancien). */
    Mono<Void> changePassword(UUID userId, String currentPassword, String newPassword);
}
