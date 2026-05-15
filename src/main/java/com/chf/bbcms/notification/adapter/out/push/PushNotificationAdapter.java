package com.chf.bbcms.notification.adapter.out.push;

import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import com.chf.bbcms.notification.application.port.out.PushSenderPort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

/**
 * Stub Push (FCM/APNS). À câbler avec firebase-admin en V2 si activé via
 * bbcms.notification.push.enabled = true.
 */
@Component
public class PushNotificationAdapter implements PushSenderPort {

    private static final Logger log = LoggerFactory.getLogger(PushNotificationAdapter.class);

    private final boolean enabled;

    public PushNotificationAdapter(@Value("${bbcms.notification.push.enabled:false}") boolean enabled) {
        this.enabled = enabled;
    }

    @Override
    public Mono<Void> send(List<UUID> userAccountIds, NotificationMessage message) {
        if (!enabled || userAccountIds == null || userAccountIds.isEmpty()) return Mono.empty();
        log.debug("[stub-push] Would push to {} users: {}", userAccountIds.size(), message.subject());
        return Mono.empty();
    }
}
