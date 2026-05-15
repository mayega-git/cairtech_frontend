package com.chf.bbcms.ratelimit;

import com.chf.bbcms.shared.adapter.in.web.ApiErrorResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.time.Duration;

/**
 * Limite à 10 requêtes par minute par IP sur les endpoints d'authentification:
 *  - POST /api/v1/bbcms/auth/login
 *  - POST /api/v1/bbcms/auth/refresh
 *  - POST /api/v1/bbcms/auth/reset-password
 *  - POST /api/v1/bbcms/users (inscription publique)
 * Renvoie HTTP 429 sinon.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 1)
public class AuthRateLimitWebFilter implements WebFilter {

    private static final String[] PROTECTED_PATHS = {
            "/api/v1/bbcms/auth/login",
            "/api/v1/bbcms/auth/refresh",
            "/api/v1/bbcms/auth/reset-password",
            "/api/v1/bbcms/users"
    };

    private final RateLimiter limiter = new RateLimiter(10, Duration.ofMinutes(1));
    private final ObjectMapper objectMapper;

    public AuthRateLimitWebFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        if (!isProtected(path)) return chain.filter(exchange);
        String key = clientKey(exchange);
        if (limiter.tryAcquire(key)) return chain.filter(exchange);
        return tooManyRequests(exchange, path);
    }

    private boolean isProtected(String path) {
        for (String p : PROTECTED_PATHS) if (path.equals(p)) return true;
        return false;
    }

    private String clientKey(ServerWebExchange exchange) {
        String fwd = exchange.getRequest().getHeaders().getFirst("X-Forwarded-For");
        if (fwd != null && !fwd.isBlank()) return fwd.split(",")[0].trim();
        var addr = exchange.getRequest().getRemoteAddress();
        return addr == null ? "unknown" : addr.getAddress().getHostAddress();
    }

    private Mono<Void> tooManyRequests(ServerWebExchange exchange, String path) {
        exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
        exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);
        ApiErrorResponse body = ApiErrorResponse.of(429, "BBCMS_RATE_LIMITED",
                "Too many requests. Please retry later.", path);
        return Mono.fromCallable(() -> objectMapper.writeValueAsBytes(body))
                .map(bytes -> exchange.getResponse().bufferFactory().wrap(bytes))
                .flatMap(b -> exchange.getResponse().writeWith(Mono.<DataBuffer>just(b)));
    }
}
