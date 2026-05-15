package com.chf.bbcms.authentication.adapter.in.security;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.Set;
import java.util.UUID;

public class BbcmsAuthenticationToken extends AbstractAuthenticationToken {

    private final UUID userId;
    private final String email;
    private final String userType;
    private final UUID bibleClubId;
    private final Set<String> permissions;

    public BbcmsAuthenticationToken(UUID userId, String email, String userType,
                                    UUID bibleClubId, Set<String> permissions) {
        super(toAuthorities(permissions));
        this.userId = userId;
        this.email = email;
        this.userType = userType;
        this.bibleClubId = bibleClubId;
        this.permissions = permissions;
        setAuthenticated(true);
    }

    private static Collection<? extends GrantedAuthority> toAuthorities(Set<String> permissions) {
        return permissions.stream()
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    @Override public Object getCredentials() { return ""; }
    @Override public Object getPrincipal()   { return userId; }

    public UUID getUserId() { return userId; }
    public String getEmail() { return email; }
    public String getUserType() { return userType; }
    public UUID getBibleClubId() { return bibleClubId; }
    public Set<String> getPermissions() { return permissions; }
}
