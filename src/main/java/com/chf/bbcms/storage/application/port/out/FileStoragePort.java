package com.chf.bbcms.storage.application.port.out;

import reactor.core.publisher.Mono;

import java.io.InputStream;
import java.util.UUID;

/**
 * Port d'abstraction pour le stockage de fichiers (photos meeting/event,
 * attestations, images Daily Verse, archives reset BBC).
 * Implémenté par MinioFileStorageAdapter.
 */
public interface FileStoragePort {

    /** Téléverse un fichier et renvoie son identifiant. */
    Mono<UUID> store(StoreRequest request);

    Mono<Void> delete(UUID fileId);

    Mono<String> presignedDownloadUrl(UUID fileId, java.time.Duration ttl);

    record StoreRequest(
            String originalFileName,
            String contentType,
            long sizeBytes,
            InputStream content
    ) {}
}
