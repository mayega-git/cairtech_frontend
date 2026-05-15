package com.chf.bbcms.settings.application.port.out;

import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.Optional;

/**
 * Port d'accès aux paramètres système (table bbcms_setting).
 * Les conventions de clés sont fixées dans 18-seed-settings.xml et constants.SettingKeys.
 */
public interface SettingsPort {

    Mono<Optional<String>> getString(String key);

    Mono<Integer> getInt(String key, int defaultValue);

    Mono<BigDecimal> getDecimal(String key, BigDecimal defaultValue);

    Mono<Void> set(String key, String value, java.util.UUID actorId);

    void invalidate(String key);
}
