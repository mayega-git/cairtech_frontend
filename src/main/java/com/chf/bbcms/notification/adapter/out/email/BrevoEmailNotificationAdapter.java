package com.chf.bbcms.notification.adapter.out.email;

import com.chf.bbcms.notification.application.port.out.EmailSenderPort;
import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@ConditionalOnProperty(name = "bbcms.notification.email.provider", havingValue = "brevo")
public class BrevoEmailNotificationAdapter implements EmailSenderPort {

    private static final Logger log = LoggerFactory.getLogger(BrevoEmailNotificationAdapter.class);
    private static final String BREVO_ENDPOINT = "https://api.brevo.com/v3/smtp/email";

    private final WebClient webClient;
    private final String fromEmail;
    private final String fromName;

    public BrevoEmailNotificationAdapter(@Value("${bbcms.notification.email.brevo.api-key}") String apiKey,
                                         @Value("${bbcms.notification.from-email}") String fromEmail,
                                         @Value("${bbcms.notification.email.brevo.from-name:BBCMS}") String fromName) {
        this.fromEmail = fromEmail;
        this.fromName = fromName;
        this.webClient = WebClient.builder()
                .baseUrl(BREVO_ENDPOINT)
                .defaultHeader("api-key", apiKey)
                .defaultHeader("accept", "application/json")
                .defaultHeader("content-type", "application/json")
                .build();
    }

    @Override
    public Mono<Void> send(List<String> emails, NotificationMessage message) {
        if (emails == null || emails.isEmpty()) return Mono.empty();

        Map<String, Object> sender = new HashMap<>();
        sender.put("email", fromEmail);
        sender.put("name", fromName);

        List<Map<String, String>> to = emails.stream()
                .map(e -> Map.of("email", e))
                .toList();

        Map<String, Object> payload = new HashMap<>();
        payload.put("sender", sender);
        payload.put("to", to);
        payload.put("subject", message.subject());
        payload.put("textContent", message.body());

        return webClient.post()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(payload)
                .retrieve()
                .bodyToMono(String.class)
                .doOnSuccess(resp -> log.debug("Brevo email sent to {} recipient(s): {}", emails.size(), message.subject()))
                .doOnError(err -> log.warn("Brevo email send failed for subject '{}': {}", message.subject(), err.getMessage()))
                .onErrorResume(err -> Mono.empty())
                .then();
    }
}
