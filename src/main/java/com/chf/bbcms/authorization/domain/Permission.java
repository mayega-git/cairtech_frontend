package com.chf.bbcms.authorization.domain;

/**
 * Permission au format bbcms:&lt;resource&gt;:&lt;action&gt;.
 * Code = clé naturelle, pas d'UUID (choix MLD).
 */
public record Permission(String code, String description) {
    public Permission {
        if (code == null || !code.matches("bbcms:[a-z\\-]+:[a-z\\-]+")) {
            throw new IllegalArgumentException("Invalid permission code: " + code);
        }
    }
}
