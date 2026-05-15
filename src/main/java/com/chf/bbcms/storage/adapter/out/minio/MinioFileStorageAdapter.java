package com.chf.bbcms.storage.adapter.out.minio;

import com.chf.bbcms.config.MinioConfig;
import com.chf.bbcms.shared.domain.BbcmsException;
import com.chf.bbcms.storage.application.port.out.FileStoragePort;
import io.minio.BucketExistsArgs;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.time.Duration;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Component
public class MinioFileStorageAdapter implements FileStoragePort {

    private static final Logger log = LoggerFactory.getLogger(MinioFileStorageAdapter.class);

    private final MinioClient client;
    private final String bucket;

    public MinioFileStorageAdapter(MinioClient client, MinioConfig.MinioProperties props) {
        this.client = client;
        this.bucket = props.getBucket();
    }

    @PostConstruct
    void ensureBucket() {
        try {
            boolean exists = client.bucketExists(BucketExistsArgs.builder().bucket(bucket).build());
            if (!exists) {
                client.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
                log.info("Created MinIO bucket {}", bucket);
            }
        } catch (Exception ex) {
            log.warn("Cannot ensure MinIO bucket '{}' exists: {}", bucket, ex.getMessage());
        }
    }

    @Override
    public Mono<UUID> store(StoreRequest request) {
        return Mono.fromCallable(() -> {
                    UUID fileId = UUID.randomUUID();
                    String objectKey = objectKeyFor(fileId, request.originalFileName());
                    client.putObject(PutObjectArgs.builder()
                            .bucket(bucket)
                            .object(objectKey)
                            .contentType(request.contentType())
                            .stream(request.content(), request.sizeBytes(), -1)
                            .build());
                    return fileId;
                })
                .subscribeOn(Schedulers.boundedElastic())
                .onErrorMap(this::wrap);
    }

    @Override
    public Mono<Void> delete(UUID fileId) {
        return Mono.fromRunnable(() -> {
                    try {
                        client.removeObject(RemoveObjectArgs.builder()
                                .bucket(bucket)
                                .object(objectPrefix(fileId))
                                .build());
                    } catch (Exception ex) {
                        throw new RuntimeException(ex);
                    }
                })
                .subscribeOn(Schedulers.boundedElastic())
                .then()
                .onErrorMap(this::wrap);
    }

    @Override
    public Mono<String> presignedDownloadUrl(UUID fileId, Duration ttl) {
        return Mono.fromCallable(() -> client.getPresignedObjectUrl(
                        GetPresignedObjectUrlArgs.builder()
                                .bucket(bucket)
                                .object(objectPrefix(fileId))
                                .method(Method.GET)
                                .expiry((int) ttl.getSeconds(), TimeUnit.SECONDS)
                                .build()))
                .subscribeOn(Schedulers.boundedElastic())
                .onErrorMap(this::wrap);
    }

    private String objectKeyFor(UUID fileId, String originalName) {
        String safe = originalName == null ? "blob" : originalName.replaceAll("[^A-Za-z0-9._-]", "_");
        return "%s/%s".formatted(fileId, safe);
    }

    private String objectPrefix(UUID fileId) {
        return fileId.toString();
    }

    private BbcmsException wrap(Throwable t) {
        return new BbcmsException("BBCMS_STORAGE_ERROR", "MinIO operation failed: " + t.getMessage(), t) {};
    }
}
