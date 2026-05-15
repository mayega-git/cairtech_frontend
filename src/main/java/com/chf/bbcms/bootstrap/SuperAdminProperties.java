package com.chf.bbcms.bootstrap;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Configuration du super-admin auto-créé au démarrage.
 * Lue depuis .env / application.yml via les clés bbcms.bootstrap.super-admin.*
 *
 * Si aucun super-admin n'existe avec cet email à l'initialisation, il est créé
 * automatiquement avec le rôle SYSTEM_ADMIN (toutes permissions).
 */
@ConfigurationProperties(prefix = "bbcms.bootstrap.super-admin")
public class SuperAdminProperties {

    /** Activer ou non le bootstrap (default true). */
    private boolean enabled = true;

    /** Email du super admin (clé d'unicité). */
    private String email;

    /** Mot de passe en clair — sera hashé en BCrypt à la création. */
    private String password;

    private String firstNames = "Super";
    private String nextNames = "Admin";

    /**
     * Si true, au prochain démarrage le mot de passe en base est ré-haché et
     * mis à jour avec la valeur de {@link #password}, même si le compte existe
     * déjà. Permet de récupérer un super-admin après un oubli de mot de passe
     * sans toucher au SQL. À remettre à false dès que la rotation est faite.
     * Lue depuis BBCMS_SUPER_ADMIN_FORCE_PASSWORD_RESET. Default false.
     */
    private boolean forcePasswordReset = false;

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFirstNames() { return firstNames; }
    public void setFirstNames(String firstNames) { this.firstNames = firstNames; }
    public String getNextNames() { return nextNames; }
    public void setNextNames(String nextNames) { this.nextNames = nextNames; }
    public boolean isForcePasswordReset() { return forcePasswordReset; }
    public void setForcePasswordReset(boolean v) { this.forcePasswordReset = v; }
}
