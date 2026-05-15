package com.chf.bbcms.ratelimit;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Rate limiter token-bucket simple, par clé (IP, user, etc.). In-memory via Caffeine.
 * Protège les endpoints sensibles (login, refresh, register) contre brute-force basique.
 * Pas de cluster-coherent — pour V1 mono-nœud c'est suffisant.
 */
public class RateLimiter {

    private final int maxRequests;
    private final Duration window;
    private final Cache<String, Bucket> buckets;

    public RateLimiter(int maxRequests, Duration window) {
        this.maxRequests = maxRequests;
        this.window = window;
        this.buckets = Caffeine.newBuilder()
                .expireAfterWrite(window.multipliedBy(2))
                .maximumSize(50_000)
                .build();
    }

    public boolean tryAcquire(String key) {
        Bucket b = buckets.get(key, k -> new Bucket(Instant.now(), new AtomicInteger(0)));
        Instant now = Instant.now();
        if (Duration.between(b.windowStart(), now).compareTo(window) > 0) {
            buckets.put(key, new Bucket(now, new AtomicInteger(1)));
            return true;
        }
        return b.count().incrementAndGet() <= maxRequests;
    }

    private record Bucket(Instant windowStart, AtomicInteger count) {}
}
