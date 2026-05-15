package com.chf.bbcms.notification.application.service;

import com.chf.bbcms.identity.application.port.out.UserAccountRepository;
import com.chf.bbcms.notification.application.port.out.EmailSenderPort;
import com.chf.bbcms.notification.application.port.out.NotificationPort;
import com.chf.bbcms.notification.application.port.out.PushSenderPort;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@Service
public class NotificationService implements NotificationPort {

    private final UserAccountRepository userRepository;
    private final EmailSenderPort emailSender;
    private final PushSenderPort pushSender;

    public NotificationService(UserAccountRepository userRepository,
                               EmailSenderPort emailSender,
                               PushSenderPort pushSender) {
        this.userRepository = userRepository;
        this.emailSender = emailSender;
        this.pushSender = pushSender;
    }

    @Override
    public Mono<Void> notifyUsers(List<UUID> userAccountIds, NotificationMessage message) {
        if (userAccountIds == null || userAccountIds.isEmpty()) return Mono.empty();
        Mono<List<String>> emails = Flux.fromIterable(userAccountIds)
                .flatMap(userRepository::findById)
                .map(u -> u.getEmail())
                .collectList();
        return emails.flatMap(list -> emailSender.send(list, message))
                .then(pushSender.send(userAccountIds, message));
    }

    @Override
    public Mono<Void> notifyEmails(List<String> emails, NotificationMessage message) {
        return emailSender.send(emails, message);
    }
}
