package com.chf.bbcms.identity.domain;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Value Object — données personnelles de l'utilisateur.
 * Source unique de vérité pour les PII (cf. décision: bbcms_member ne les duplique pas).
 */
public record UserProfile(
        String firstNames,
        String nextNames,
        LocalDate dateOfBirth,
        Gender gender,
        LocalDate dateBornAgain,
        String howBornAgain,
        LocalDate dateEntered,
        UUID pictureFileId
) {
    public UserProfile {
        if (firstNames == null || firstNames.isBlank()) {
            throw new IllegalArgumentException("firstNames is required");
        }
    }
}
