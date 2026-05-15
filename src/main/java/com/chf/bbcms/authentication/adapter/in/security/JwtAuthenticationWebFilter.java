package com.chf.bbcms.authentication.adapter.in.security;

import com.chf.bbcms.authentication.application.port.out.JwtIssuer;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContextImpl;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationWebFilter implements WebFilter {

    private final JwtIssuer jwtIssuer;

    public JwtAuthenticationWebFilter(JwtIssuer jwtIssuer) {
        this.jwtIssuer = jwtIssuer;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String header = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (header == null || !header.startsWith("Bearer ")) {
            return chain.filter(exchange);
        }
        String token = header.substring(7);
        try {
            JwtIssuer.JwtClaims claims = jwtIssuer.parseAndValidate(token);
            BbcmsAuthenticationToken auth = new BbcmsAuthenticationToken(
                    claims.userId(), claims.email(), claims.userType(),
                    claims.bibleClubId(), claims.permissions());
            return chain.filter(exchange)
                    .contextWrite(ReactiveSecurityContextHolder.withSecurityContext(
                            Mono.just(new SecurityContextImpl(auth))));
        } catch (Exception ignored) {
            // Token invalide → on continue sans authentication; ResourceServer le rejettera si nécessaire
            return chain.filter(exchange);
        }
    }
}
