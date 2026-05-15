package com.chf.bbcms.shared.domain;

public abstract class BbcmsException extends RuntimeException {
    private final String code;

    protected BbcmsException(String code, String message) {
        super(message);
        this.code = code;
    }

    protected BbcmsException(String code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }

    public String getCode() { return code; }
}
