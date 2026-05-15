package com.chf.bbcms.ratelimit;

import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.*;

class RateLimiterTest {

    @Test
    void allows_up_to_max_requests_in_window() {
        RateLimiter rl = new RateLimiter(3, Duration.ofMinutes(1));
        assertTrue(rl.tryAcquire("ip-1"));
        assertTrue(rl.tryAcquire("ip-1"));
        assertTrue(rl.tryAcquire("ip-1"));
        assertFalse(rl.tryAcquire("ip-1"));
    }

    @Test
    void different_keys_have_independent_buckets() {
        RateLimiter rl = new RateLimiter(2, Duration.ofMinutes(1));
        assertTrue(rl.tryAcquire("a"));
        assertTrue(rl.tryAcquire("a"));
        assertTrue(rl.tryAcquire("b"));
        assertTrue(rl.tryAcquire("b"));
        assertFalse(rl.tryAcquire("a"));
        assertFalse(rl.tryAcquire("b"));
    }

    @Test
    void window_expiry_resets_count() throws InterruptedException {
        RateLimiter rl = new RateLimiter(1, Duration.ofMillis(50));
        assertTrue(rl.tryAcquire("k"));
        assertFalse(rl.tryAcquire("k"));
        Thread.sleep(80);
        assertTrue(rl.tryAcquire("k"));
    }
}
