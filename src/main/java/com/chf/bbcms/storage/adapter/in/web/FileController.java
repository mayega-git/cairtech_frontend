package com.chf.bbcms.storage.adapter.in.web;

import com.chf.bbcms.storage.application.port.in.FileStorageUseCase;
import com.chf.bbcms.storage.application.port.in.FileStorageUseCase.UploadCommand;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.io.ByteArrayInputStream;
import java.time.Duration;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/files")
public class FileController {

    private final FileStorageUseCase useCase;

    public FileController(FileStorageUseCase useCase) {
        this.useCase = useCase;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<UploadResponse> upload(@RequestPart("file") FilePart file,
                                       @RequestPart(value = "size", required = false) String sizeStr) {
        long declaredSize = sizeStr == null ? -1L : Long.parseLong(sizeStr);
        return readAllBytes(file).flatMap(bytes -> {
            long size = declaredSize > 0 ? declaredSize : bytes.length;
            String contentType = file.headers().getContentType() == null
                    ? MediaType.APPLICATION_OCTET_STREAM_VALUE
                    : file.headers().getContentType().toString();
            return useCase.upload(new UploadCommand(
                            file.filename(), contentType, size,
                            new ByteArrayInputStream(bytes)))
                    .map(r -> new UploadResponse(r.id(), r.presignedUrl()));
        });
    }

    @GetMapping("/{id}/url")
    public Mono<UrlResponse> url(@PathVariable UUID id,
                                 @RequestParam(value = "ttlSeconds", required = false) Long ttlSeconds) {
        Duration ttl = ttlSeconds == null ? Duration.ofHours(1) : Duration.ofSeconds(ttlSeconds);
        return useCase.presignedUrl(id, ttl).map(UrlResponse::new);
    }

    @GetMapping("/{id}")
    public Mono<ResponseEntity<Void>> downloadOrRedirect(@PathVariable UUID id) {
        return useCase.presignedUrl(id, Duration.ofHours(1))
                .map(url -> ResponseEntity.status(HttpStatus.FOUND)
                        .location(java.net.URI.create(url))
                        .build());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> delete(@PathVariable UUID id) {
        return useCase.delete(id);
    }

    private static Mono<byte[]> readAllBytes(FilePart part) {
        return DataBufferUtils.join(part.content())
                .map(buffer -> {
                    byte[] bytes = new byte[buffer.readableByteCount()];
                    buffer.read(bytes);
                    DataBufferUtils.release(buffer);
                    return bytes;
                });
    }

    public record UploadResponse(UUID id, String url) {}
    public record UrlResponse(String url) {}
}
