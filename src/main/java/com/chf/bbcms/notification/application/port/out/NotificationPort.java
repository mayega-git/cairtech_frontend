package com.chf.bbcms.notification.application.port.out;

import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

/**
 * Port unifié pour notifier les utilisateurs (push, email, sms).
 * Les implémentations adapter/out/* dispatchent selon les canaux activés.
 */
public interface NotificationPort {

    Mono<Void> notifyUsers(List<UUID> userAccountIds, NotificationMessage message);

    Mono<Void> notifyEmails(List<String> emails, NotificationMessage message);

    record NotificationMessage(
            String subject,
            String body,
            Channel channel,
            String deepLink
    ) {
        public static NotificationMessage email(String subject, String body) {
            return new NotificationMessage(subject, body, Channel.EMAIL, null);
        }
        public static NotificationMessage push(String subject, String body, String deepLink) {
            return new NotificationMessage(subject, body, Channel.PUSH, deepLink);
        }
    }

    enum Channel { EMAIL, PUSH, SMS }
}
