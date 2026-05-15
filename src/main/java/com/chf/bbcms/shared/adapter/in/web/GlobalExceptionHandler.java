package com.chf.bbcms.shared.adapter.in.web;

import com.chf.bbcms.shared.domain.BbcmsException;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import com.chf.bbcms.shared.domain.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.bind.support.WebExchangeBindException;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    public Mono<ResponseEntity<ApiErrorResponse>> notFound(NotFoundException ex, ServerWebExchange exchange) {
        return Mono.just(ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                ApiErrorResponse.of(404, ex.getCode(), ex.getMessage(), exchange.getRequest().getPath().value())));
    }

    @ExceptionHandler(BusinessRuleViolation.class)
    public Mono<ResponseEntity<ApiErrorResponse>> businessRule(BusinessRuleViolation ex, ServerWebExchange exchange) {
        return Mono.just(ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(
                ApiErrorResponse.of(422, ex.getCode(), ex.getMessage(), exchange.getRequest().getPath().value())));
    }

    @ExceptionHandler(BbcmsException.class)
    public Mono<ResponseEntity<ApiErrorResponse>> bbcms(BbcmsException ex, ServerWebExchange exchange) {
        return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                ApiErrorResponse.of(400, ex.getCode(), ex.getMessage(), exchange.getRequest().getPath().value())));
    }

    @ExceptionHandler(WebExchangeBindException.class)
    public Mono<ResponseEntity<ApiErrorResponse>> validation(WebExchangeBindException ex, ServerWebExchange exchange) {
        var fieldErrors = ex.getFieldErrors().stream()
                .map(fe -> new ApiErrorResponse.FieldError(fe.getField(), fe.getDefaultMessage()))
                .toList();
        var body = new ApiErrorResponse(
                java.time.Instant.now(), 400, "BBCMS_VALIDATION", "Validation failed",
                exchange.getRequest().getPath().value(), fieldErrors);
        return Mono.just(ResponseEntity.badRequest().body(body));
    }

    @ExceptionHandler(AuthenticationException.class)
    public Mono<ResponseEntity<ApiErrorResponse>> auth(AuthenticationException ex, ServerWebExchange exchange) {
        return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                ApiErrorResponse.of(401, "BBCMS_UNAUTHORIZED", ex.getMessage(), exchange.getRequest().getPath().value())));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public Mono<ResponseEntity<ApiErrorResponse>> denied(AccessDeniedException ex, ServerWebExchange exchange) {
        return Mono.just(ResponseEntity.status(HttpStatus.FORBIDDEN).body(
                ApiErrorResponse.of(403, "BBCMS_FORBIDDEN", ex.getMessage(), exchange.getRequest().getPath().value())));
    }
}
