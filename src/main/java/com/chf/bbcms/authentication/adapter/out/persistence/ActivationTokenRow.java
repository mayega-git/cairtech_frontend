package com.chf.bbcms.authentication.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_activation_token")
public class ActivationTokenRow {
    @Id private UUID id;
    @Column("user_account_id") private UUID userAccountId;
    private String token;
    @Column("expires_at") private Instant expiresAt;
    private boolean used;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getUserAccountId() { return userAccountId; }
    public void setUserAccountId(UUID userAccountId) { this.userAccountId = userAccountId; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public Instant getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Instant expiresAt) { this.expiresAt = expiresAt; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }
}
