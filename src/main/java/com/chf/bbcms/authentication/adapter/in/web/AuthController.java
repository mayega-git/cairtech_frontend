package com.chf.bbcms.authentication.adapter.in.web;

import com.chf.bbcms.authentication.adapter.in.security.BbcmsAuthenticationToken;
import com.chf.bbcms.authentication.application.port.in.AuthenticationUseCase;
import com.chf.bbcms.identity.application.port.in.ManageUserAccountUseCase;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/auth")
public class AuthController {

    private final AuthenticationUseCase authentication;
    private final ManageUserAccountUseCase userAccount;

    public AuthController(AuthenticationUseCase authentication,
                          ManageUserAccountUseCase userAccount) {
        this.authentication = authentication;
        this.userAccount = userAccount;
    }

    @PostMapping("/login")
    public Mono<TokenPairResponse> login(@Valid @RequestBody LoginRequest request) {
        return authentication.login(request.email(), request.password())
                .map(TokenPairResponse::from);
    }

    @PostMapping("/refresh")
    public Mono<TokenPairResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return authentication.refresh(request.refreshToken())
                .map(TokenPairResponse::from);
    }

    @PostMapping("/logout")
    public Mono<Void> logout(@Valid @RequestBody RefreshRequest request) {
        return authentication.logout(request.refreshToken());
    }

    /**
     * Demande l'envoi d'un email de réinitialisation de mot de passe.
     * Réponse 204 quoi qu'il arrive (anti enumeration).
     */
    @PostMapping("/reset-password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> requestPasswordReset(@Valid @RequestBody ResetPasswordRequest req) {
        return userAccount.requestPasswordReset(req.email());
    }

    /**
     * Consomme le token reçu par email et applique le nouveau mot de passe.
     */
    @PostMapping("/reset-password/confirm")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> confirmPasswordReset(@Valid @RequestBody ConfirmResetRequest req) {
        return userAccount.confirmPasswordReset(req.token(), req.newPassword());
    }

    /**
     * Change le mot de passe de l'utilisateur connecté (vérifie l'ancien).
     */
    @PostMapping("/change-password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> changePassword(@Valid @RequestBody ChangePasswordRequest req) {
        return ReactiveSecurityContextHolder.getContext()
                .map(ctx -> ((BbcmsAuthenticationToken) ctx.getAuthentication()).getUserId())
                .flatMap(userId -> userAccount.changePassword(
                        userId, req.currentPassword(), req.newPassword()));
    }

    public record LoginRequest(
            @NotBlank @Email String email,
            @NotBlank @Size(min = 8, max = 100) String password
    ) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record ResetPasswordRequest(@NotBlank @Email String email) {}

    public record ConfirmResetRequest(
            @NotBlank String token,
            @NotBlank @Size(min = 8, max = 100) String newPassword
    ) {}

    public record ChangePasswordRequest(
            @NotBlank @Size(min = 8, max = 100) String currentPassword,
            @NotBlank @Size(min = 8, max = 100) String newPassword
    ) {}

    public record TokenPairResponse(
            String accessToken, String refreshToken, long accessTokenExpiresInSeconds, String tokenType
    ) {
        static TokenPairResponse from(AuthenticationUseCase.TokenPair pair) {
            return new TokenPairResponse(
                    pair.accessToken(), pair.refreshToken(),
                    pair.accessTokenExpiresInSeconds(), "Bearer");
        }
    }
}
