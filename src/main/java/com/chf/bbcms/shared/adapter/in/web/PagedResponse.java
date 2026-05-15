package com.chf.bbcms.shared.adapter.in.web;

import java.util.List;

public record PagedResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
    public static <T> PagedResponse<T> of(List<T> content, int page, int size, long totalElements) {
        int totalPages = size == 0 ? 0 : (int) Math.ceil(totalElements / (double) size);
        return new PagedResponse<>(content, page, size, totalElements, totalPages);
    }
}
