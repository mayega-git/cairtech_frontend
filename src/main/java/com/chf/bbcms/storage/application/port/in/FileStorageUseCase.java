package com.chf.bbcms.storage.application.port.in;

import reactor.core.publisher.Mono;

import java.io.InputStream;
import java.time.Duration;
import java.util.UUID;

public interface FileStorageUseCase {

    Mono<UploadResult> upload(UploadCommand command);

    Mono<Void> delete(UUID fileId);

    Mono<String> presignedUrl(UUID fileId, Duration ttl);

    record UploadCommand(String originalFileName, String contentType, long sizeBytes, InputStream content) {}

    record UploadResult(UUID id, String presignedUrl) {}
}
