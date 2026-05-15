package com.chf.bbcms.storage.application.service;

import com.chf.bbcms.storage.application.port.in.FileStorageUseCase;
import com.chf.bbcms.storage.application.port.out.FileStoragePort;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.UUID;

@Service
public class FileStorageService implements FileStorageUseCase {

    private static final Duration DEFAULT_TTL = Duration.ofHours(1);

    private final FileStoragePort storage;

    public FileStorageService(FileStoragePort storage) {
        this.storage = storage;
    }

    @Override
    public Mono<UploadResult> upload(UploadCommand command) {
        return storage.store(new FileStoragePort.StoreRequest(
                        command.originalFileName(),
                        command.contentType(),
                        command.sizeBytes(),
                        command.content()))
                .flatMap(id -> storage.presignedDownloadUrl(id, DEFAULT_TTL)
                        .map(url -> new UploadResult(id, url)));
    }

    @Override
    public Mono<Void> delete(UUID fileId) {
        return storage.delete(fileId);
    }

    @Override
    public Mono<String> presignedUrl(UUID fileId, Duration ttl) {
        return storage.presignedDownloadUrl(fileId, ttl == null ? DEFAULT_TTL : ttl);
    }
}
