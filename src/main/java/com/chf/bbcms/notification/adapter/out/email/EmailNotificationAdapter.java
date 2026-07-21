package com.chf.bbcms.notification.adapter.out.email;

import com.chf.bbcms.notification.application.port.out.EmailSenderPort;
import com.chf.bbcms.notification.application.port.out.NotificationPort.NotificationMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.util.List;

@Component
@ConditionalOnProperty(name = "bbcms.notification.email.provider", havingValue = "smtp", matchIfMissing = true)
public class EmailNotificationAdapter implements EmailSenderPort {

    private static final Logger log = LoggerFactory.getLogger(EmailNotificationAdapter.class);

    private final JavaMailSender mailSender;
    private final String fromEmail;

    public EmailNotificationAdapter(JavaMailSender mailSender,
                                    @Value("${bbcms.notification.from-email}") String fromEmail) {
        this.mailSender = mailSender;
        this.fromEmail = fromEmail;
    }

    @Override
    public Mono<Void> send(List<String> emails, NotificationMessage message) {
        if (emails == null || emails.isEmpty()) return Mono.empty();
        return Mono.fromRunnable(() -> {
                    SimpleMailMessage mail = new SimpleMailMessage();
                    mail.setFrom(fromEmail);
                    mail.setTo(emails.toArray(new String[0]));
                    mail.setSubject(message.subject());
                    mail.setText(message.body());
                    try {
                        mailSender.send(mail);
                        log.debug("Email sent to {} recipient(s): {}", emails.size(), message.subject());
                    } catch (Exception ex) {
                        log.warn("Email send failed for subject '{}': {}", message.subject(), ex.getMessage());
                    }
                })
                .subscribeOn(Schedulers.boundedElastic())
                .then();
    }
}
