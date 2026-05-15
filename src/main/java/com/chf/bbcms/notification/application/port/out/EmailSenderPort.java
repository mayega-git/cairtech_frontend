package com.chf.bbcms.notification.application.port.out;

import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import reactor.core.publisher.Mono;

import java.util.List;

public interface EmailSenderPort {
    Mono<Void> send(List<String> emails, NotificationMessage message);
}
