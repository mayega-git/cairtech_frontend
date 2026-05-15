package com.chf.bbcms.notification.adapter.out.sms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.util.List;

/**
 * Stub SMS (Twilio / Orange API). À câbler en V2 si activé via
 * bbcms.notification.sms.enabled = true.
 */
@Component
public class SmsNotificationAdapter {

    private static final Logger log = LoggerFactory.getLogger(SmsNotificationAdapter.class);

    private final boolean enabled;

    public SmsNotificationAdapter(@Value("${bbcms.notification.sms.enabled:false}") boolean enabled) {
        this.enabled = enabled;
    }

    public Mono<Void> send(List<String> phoneNumbers, String body) {
        if (!enabled || phoneNumbers == null || phoneNumbers.isEmpty()) return Mono.empty();
        log.debug("[stub-sms] Would send to {} number(s)", phoneNumbers.size());
        return Mono.empty();
    }
}
