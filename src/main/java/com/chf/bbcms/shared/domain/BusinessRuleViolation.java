package com.chf.bbcms.shared.domain;

public class BusinessRuleViolation extends BbcmsException {
    public BusinessRuleViolation(String code, String message) {
        super(code, message);
    }
}
