package com.chf.bbcms.notification.application.port.out;

import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

public interface PushSenderPort {
    Mono<Void> send(List<UUID> userAccountIds, NotificationMessage message);
}
