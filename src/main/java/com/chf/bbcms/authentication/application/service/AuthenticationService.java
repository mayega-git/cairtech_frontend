package com.chf.bbcms.authentication.application.service;

import com.chf.bbcms.authentication.application.port.in.AuthenticationUseCase;
import com.chf.bbcms.authentication.application.port.out.JwtIssuer;
import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import com.chf.bbcms.authentication.application.port.out.RefreshTokenRepository;
import com.chf.bbcms.authentication.domain.RefreshToken;
import com.chf.bbcms.authorization.application.service.AuthorizationService;
import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserStatus;
import com.chf.bbcms.people.application.port.out.MemberRepository;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.time.Instant;
import java.util.Set;

@Service
public class AuthenticationService implements AuthenticationUseCase {

    private final UserAccountRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordHasher passwordHasher;
    private final JwtIssuer jwtIssuer;
    private final AuthorizationService authorizationService;
    private final MemberRepository memberRepository;
    private final Duration refreshTtl;
    private final Duration accessTtl;

    public AuthenticationService(UserAccountRepository userRepository,
                                 RefreshTokenRepository refreshTokenRepository,
                                 PasswordHasher passwordHasher,
                                 JwtIssuer jwtIssuer,
                                 AuthorizationService authorizationService,
                                 MemberRepository memberRepository,
                                 @Value("${bbcms.security.jwt.refresh-token-ttl}") Duration refreshTtl,
                                 @Value("${bbcms.security.jwt.access-token-ttl}") Duration accessTtl) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordHasher = passwordHasher;
        this.jwtIssuer = jwtIssuer;
        this.authorizationService = authorizationService;
        this.memberRepository = memberRepository;
        this.refreshTtl = refreshTtl;
        this.accessTtl = accessTtl;
    }

    @Override
    public Mono<TokenPair> login(String email, String plainPassword) {
        return userRepository.findByEmail(email)
                .switchIfEmpty(Mono.error(badCreds()))
                .flatMap(account -> passwordHasher.matches(plainPassword, account.getPasswordHash())
                        .flatMap(ok -> {
                            if (!ok) return Mono.error(badCreds());
                            if (account.getStatus() != UserStatus.ACTIVE)
                                return Mono.error(new BusinessRuleViolation("BBCMS_USER_NOT_ACTIVE",
                                        "Account is not active (status=" + account.getStatus() + ")"));
                            account.recordLogin(Instant.now());
                            return userRepository.save(account).thenReturn(account);
                        }))
                .flatMap(this::issueTokenPair);
    }

    @Override
    public Mono<TokenPair> refresh(String refreshTokenClear) {
        String hash = RefreshToken.hashFor(refreshTokenClear);
        return refreshTokenRepository.findByHash(hash)
                .switchIfEmpty(Mono.error(badCreds()))
                .flatMap(token -> {
                    token.ensureUsable();
                    token.revoke();
                    return refreshTokenRepository.save(token)
                            .then(userRepository.findById(token.getUserAccountId()))
                            .switchIfEmpty(Mono.error(badCreds()))
                            .flatMap(this::issueTokenPair);
                });
    }

    @Override
    public Mono<Void> logout(String refreshTokenClear) {
        String hash = RefreshToken.hashFor(refreshTokenClear);
        return refreshTokenRepository.findByHash(hash)
                .flatMap(token -> {
                    token.revoke();
                    return refreshTokenRepository.save(token);
                })
                .then();
    }

    private Mono<TokenPair> issueTokenPair(UserAccount account) {
        Mono<Set<String>> permissionsMono = authorizationService.permissionsOf(account.getId());
        // Récupère le bibleClubId du Member STUDENT (si l'utilisateur en a un).
        // Pour PROFESSIONAL/MENTOR/NATIONAL_LEADER/SYSTEM_ADMIN: pas de scope BBC unique
        // → Mono empty → bibleClubId restera null dans le JWT.
        // NB: `Mono.defaultIfEmpty(null)` jette une NPE — on utilise un sentinel UUID(0,0)
        // ré-interprété comme null après le zip (Mono ne porte pas de valeurs null).
        Mono<java.util.UUID> bibleClubIdMono = memberRepository.findByUserAccountId(account.getId())
                .flatMap(m -> Mono.justOrEmpty(m.getBibleClubId()));

        return Mono.zip(permissionsMono, bibleClubIdMono.defaultIfEmpty(new java.util.UUID(0L, 0L)))
                .flatMap(tuple -> {
                    Set<String> permissions = tuple.getT1();
                    java.util.UUID rawBbcId = tuple.getT2();
                    java.util.UUID bibleClubId = (rawBbcId.getMostSignificantBits() == 0L
                            && rawBbcId.getLeastSignificantBits() == 0L) ? null : rawBbcId;

                    JwtIssuer.JwtClaims claims = new JwtIssuer.JwtClaims(
                            account.getId(),
                            account.getEmail(),
                            account.getUserType().name(),
                            Set.of(),
                            permissions,
                            bibleClubId,
                            Instant.now(),
                            Instant.now().plus(accessTtl)
                    );
                    String accessToken = jwtIssuer.issueAccessToken(claims);
                    RefreshToken refresh = RefreshToken.issue(account.getId(), refreshTtl);
                    String clear = refresh.getClearText();
                    return refreshTokenRepository.save(refresh)
                            .thenReturn(new TokenPair(accessToken, clear, accessTtl.toSeconds()));
                });
    }

    private static BusinessRuleViolation badCreds() {
        return new BusinessRuleViolation("BBCMS_BAD_CREDENTIALS", "Invalid email or password");
    }
}
