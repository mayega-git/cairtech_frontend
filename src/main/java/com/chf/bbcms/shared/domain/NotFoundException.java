package com.chf.bbcms.shared.domain;

public class NotFoundException extends BbcmsException {
    public NotFoundException(String resource, Object id) {
        super("BBCMS_NOT_FOUND", "%s not found: %s".formatted(resource, id));
    }
}
