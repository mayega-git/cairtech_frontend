package com.chf.bbcms.settings.adapter.out.persistence;

import com.chf.bbcms.settings.application.port.out.SettingsPort;
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

/**
 * Adapter SettingsPort: lecture en cache Caffeine, écriture en DB.
 * Le cache est invalidé manuellement (set/invalidate) ou expire après 5 minutes.
 */
@Component
public class InAppSettingsAdapter implements SettingsPort {

    private final R2dbcEntityTemplate template;
    private final Cache<String, String> cache;

    public InAppSettingsAdapter(R2dbcEntityTemplate template) {
        this.template = template;
        this.cache = Caffeine.newBuilder()
                .maximumSize(500)
                .expireAfterWrite(Duration.ofMinutes(5))
                .build();
    }

    @Override
    public Mono<Optional<String>> getString(String key) {
        String cached = cache.getIfPresent(key);
        if (cached != null) return Mono.just(Optional.of(cached));
        return template.selectOne(Query.query(Criteria.where("key").is(key)), SettingRow.class)
                .map(SettingRow::getValue)
                .doOnNext(v -> cache.put(key, v))
                .map(Optional::of)
                .defaultIfEmpty(Optional.empty());
    }

    @Override
    public Mono<Integer> getInt(String key, int defaultValue) {
        return getString(key).map(opt -> opt.map(Integer::parseInt).orElse(defaultValue));
    }

    @Override
    public Mono<BigDecimal> getDecimal(String key, BigDecimal defaultValue) {
        return getString(key).map(opt -> opt.map(BigDecimal::new).orElse(defaultValue));
    }

    @Override
    public Mono<Void> set(String key, String value, UUID actorId) {
        SettingRow row = new SettingRow();
        row.setKey(key);
        row.setValue(value);
        row.setUpdatedBy(actorId);
        row.setUpdatedAt(Instant.now());
        return template.exists(Query.query(Criteria.where("key").is(key)), SettingRow.class)
                .flatMap(exists -> Boolean.TRUE.equals(exists)
                        ? template.update(row)
                        : template.insert(row))
                .doOnSuccess(r -> cache.put(key, value))
                .then();
    }

    @Override
    public void invalidate(String key) {
        cache.invalidate(key);
    }
}
