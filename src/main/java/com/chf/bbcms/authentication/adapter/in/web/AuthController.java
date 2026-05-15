package com.chf.bbcms.authentication.adapter.in.web;

import com.chf.bbcms.authentication.application.port.in.AuthenticationUseCase;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/v1/bbcms/auth")
public class AuthController {

    private final AuthenticationUseCase authentication;

    public AuthController(AuthenticationUseCase authentication) {
        this.authentication = authentication;
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

    public record LoginRequest(
            @NotBlank @Email String email,
            @NotBlank @Size(min = 8, max = 100) String password
    ) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

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
