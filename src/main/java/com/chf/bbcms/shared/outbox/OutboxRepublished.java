package com.chf.bbcms.shared.outbox;

import java.util.UUID;

/**
 * Wrapper pour la republication via Spring ApplicationEventPublisher.
 * Les listeners s'abonnent en filtrant sur le type.
 */
public record OutboxRepublished(String type, UUID aggregateId, String payloadJson) {}
