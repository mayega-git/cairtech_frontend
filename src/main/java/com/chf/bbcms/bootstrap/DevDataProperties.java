package com.chf.bbcms.bootstrap;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Active/désactive le seed de données fictives au démarrage (dev / staging).
 * Lue depuis bbcms.bootstrap.dev-data.* (BBCMS_DEV_DATA_ENABLED).
 *
 * Le seed est idempotent : si au moins un BBC existe déjà en base, le
 * seeder s'abstient pour ne pas dupliquer les données ni écraser le travail
 * réel.
 */
@ConfigurationProperties(prefix = "bbcms.bootstrap.dev-data")
public class DevDataProperties {

    /** Activer ou non le seed de démo. Default true en dev. */
    private boolean enabled = true;

    /** Mot de passe par défaut des comptes de démo (BCrypt-hashé à la création). */
    private String defaultPassword = "Demo_2025!";

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public String getDefaultPassword() { return defaultPassword; }
    public void setDefaultPassword(String defaultPassword) { this.defaultPassword = defaultPassword; }
}
