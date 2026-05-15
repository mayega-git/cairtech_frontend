package com.chf.bbcms.identity.application.service;

import com.chf.bbcms.authentication.application.port.out.ActivationTokenRepository;
import com.chf.bbcms.authentication.application.port.out.PasswordHasher;
import com.chf.bbcms.authentication.application.port.out.PasswordResetTokenRepository;
import com.chf.bbcms.authentication.domain.ActivationToken;
import com.chf.bbcms.authentication.domain.PasswordResetToken;
import com.chf.bbcms.identity.application.port.in.ManageUserAccountUseCase;
import com.chf.bbcms.identity.application.port.in.RegisterUserCommand;
import com.chf.bbcms.identity.application.port.out.MembershipRequestRepository;
import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.identity.domain.MembershipRequest;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserProfile;
import com.chf.bbcms.identity.domain.UserType;
import com.chf.bbcms.notification.application.port.out.NotificationPort;
import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.reactive.TransactionalOperator;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.List;
import java.util.UUID;

@Service
public class UserAccountService implements ManageUserAccountUseCase {

    private static final Logger log = LoggerFactory.getLogger(UserAccountService.class);

    private static final Duration ACTIVATION_TTL = Duration.ofDays(7);
    private static final Duration RESET_TOKEN_TTL = Duration.ofHours(2);

    private final UserAccountRepository userRepository;
    private final ActivationTokenRepository activationTokenRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final MembershipRequestRepository membershipRequestRepository;
    private final PasswordHasher passwordHasher;
    private final NotificationPort notificationPort;
    private final TransactionalOperator txOperator;
    private final String frontendBaseUrl;

    public UserAccountService(UserAccountRepository userRepository,
                              ActivationTokenRepository activationTokenRepository,
                              PasswordResetTokenRepository passwordResetTokenRepository,
                              MembershipRequestRepository membershipRequestRepository,
                              PasswordHasher passwordHasher,
                              NotificationPort notificationPort,
                              TransactionalOperator txOperator,
                              @Value("${bbcms.frontend.base-url:http://localhost:3000}") String frontendBaseUrl) {
        this.userRepository = userRepository;
        this.activationTokenRepository = activationTokenRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.membershipRequestRepository = membershipRequestRepository;
        this.passwordHasher = passwordHasher;
        this.notificationPort = notificationPort;
        this.txOperator = txOperator;
        this.frontendBaseUrl = frontendBaseUrl;
    }

    @Override
    public Mono<UserAccount> register(RegisterUserCommand cmd) {
        return userRepository.existsByEmail(cmd.email())
                .flatMap(exists -> {
                    if (Boolean.TRUE.equals(exists)) {
                        return Mono.error(new BusinessRuleViolation(
                                "BBCMS_EMAIL_TAKEN", "Email already registered: " + cmd.email()));
                    }
                    return passwordHasher.hash(cmd.plainPassword())
                            .flatMap(hash -> {
                                UserProfile profile = new UserProfile(
                                        cmd.firstNames(), cmd.nextNames(), cmd.dateOfBirth(),
                                        cmd.gender(), null, null, null, cmd.pictureFileId());
                                UserAccount account = UserAccount.register(
                                        cmd.email(), hash, cmd.phone(), profile, cmd.locale());
                                return userRepository.save(account)
                                        .flatMap(saved -> activationTokenRepository
                                                .save(ActivationToken.issue(saved.getId(), ACTIVATION_TTL))
                                                .flatMap(tok -> sendActivationEmail(saved, tok.getToken())
                                                        .onErrorResume(ex -> {
                                                            log.warn("Activation email could not be sent: {}",
                                                                    ex.getMessage());
                                                            return Mono.empty();
                                                        }))
                                                .then(maybeSubmitMembershipRequest(saved.getId(), cmd))
                                                .thenReturn(saved));
                            });
                })
                .as(txOperator::transactional);
    }

    @Override
    public Mono<UserAccount> activateByToken(String activationToken) {
        return activationTokenRepository.findByToken(activationToken)
                .switchIfEmpty(Mono.error(new NotFoundException("ActivationToken", activationToken)))
                .flatMap(token -> {
                    token.consume();
                    return activationTokenRepository.save(token)
                            .then(userRepository.findById(token.getUserAccountId()))
                            .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", token.getUserAccountId())))
                            .flatMap(account -> {
                                account.activate();
                                return userRepository.save(account);
                            });
                })
                .as(txOperator::transactional);
    }

    @Override
    public Mono<UserAccount> findById(UUID id) {
        return userRepository.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", id)));
    }

    @Override
    public Mono<Void> requestPasswordReset(String email) {
        if (email == null || email.isBlank()) return Mono.empty();
        return userRepository.findByEmail(email.trim().toLowerCase())
                .flatMap(user -> passwordResetTokenRepository
                        .save(PasswordResetToken.issue(user.getId(), RESET_TOKEN_TTL))
                        .flatMap(tok -> sendPasswordResetEmail(user, tok.getToken())))
                // Réponse silencieuse si l'email n'existe pas (anti-enumeration).
                .onErrorResume(ex -> {
                    log.warn("Password reset failed silently for {}: {}", email, ex.getMessage());
                    return Mono.empty();
                })
                .then();
    }

    @Override
    public Mono<Void> confirmPasswordReset(String token, String newPassword) {
        return passwordResetTokenRepository.findByToken(token)
                .switchIfEmpty(Mono.error(new NotFoundException("PasswordResetToken", token)))
                .flatMap(t -> {
                    t.consume();
                    return passwordResetTokenRepository.save(t)
                            .then(userRepository.findById(t.getUserAccountId()))
                            .switchIfEmpty(Mono.error(new NotFoundException(
                                    "UserAccount", t.getUserAccountId())))
                            .flatMap(user -> passwordHasher.hash(newPassword)
                                    .flatMap(hash -> {
                                        user.changePasswordHash(hash);
                                        return userRepository.save(user);
                                    }));
                })
                .then()
                .as(txOperator::transactional);
    }

    @Override
    public Mono<Void> changePassword(UUID userId, String currentPassword, String newPassword) {
        return userRepository.findById(userId)
                .switchIfEmpty(Mono.error(new NotFoundException("UserAccount", userId)))
                .flatMap(user -> passwordHasher.matches(currentPassword, user.getPasswordHash())
                        .flatMap(ok -> {
                            if (Boolean.FALSE.equals(ok)) {
                                return Mono.error(new BusinessRuleViolation(
                                        "BBCMS_WRONG_CURRENT_PASSWORD",
                                        "Current password is incorrect"));
                            }
                            return passwordHasher.hash(newPassword).flatMap(hash -> {
                                user.changePasswordHash(hash);
                                return userRepository.save(user);
                            });
                        }))
                .then();
    }

    private Mono<?> maybeSubmitMembershipRequest(UUID userAccountId, RegisterUserCommand cmd) {
        UserType type = cmd.requestedType();
        if (type == null || type == UserType.VISITOR) return Mono.empty();
        MembershipRequest req = MembershipRequest.submit(userAccountId, type,
                cmd.bibleClubId(), cmd.levelId(), cmd.profession());
        return membershipRequestRepository.save(req);
    }

    private Mono<Void> sendActivationEmail(UserAccount user, String token) {
        String link = "%s/activate?token=%s".formatted(frontendBaseUrl, token);
        String body = """
                Bonjour %s,

                Bienvenue dans la communauté BBCMS (CHF).
                Pour activer votre compte, cliquez sur le lien ci-dessous :

                %s

                Ce lien est valable 7 jours. Si vous n'êtes pas à l'origine
                de cette inscription, ignorez ce message.

                — L'équipe BBCMS · CHF
                """.formatted(user.getProfile().firstNames(), link);
        return notificationPort.notifyEmails(
                List.of(user.getEmail()),
                NotificationMessage.email("Activez votre compte BBCMS", body));
    }

    private Mono<Void> sendPasswordResetEmail(UserAccount user, String token) {
        String link = "%s/reset-password?token=%s".formatted(frontendBaseUrl, token);
        String body = """
                Bonjour %s,

                Vous avez demandé la réinitialisation de votre mot de passe BBCMS.
                Cliquez sur le lien ci-dessous pour en choisir un nouveau :

                %s

                Ce lien est valable 2 heures. Si vous n'êtes pas à l'origine de
                cette demande, ignorez ce message — votre compte reste protégé.

                — L'équipe BBCMS · CHF
                """.formatted(user.getProfile().firstNames(), link);
        return notificationPort.notifyEmails(
                List.of(user.getEmail()),
                NotificationMessage.email("Réinitialisation de votre mot de passe", body));
    }
}
