package com.chf.bbcms.authorization.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.util.Collections;
import java.util.Set;
import java.util.UUID;

public class Role extends BaseEntity {

    private String name;
    private String description;
    private Set<String> permissionCodes;

    protected Role() {}

    public static Role rehydrate(UUID id, String name, String description, Set<String> permissionCodes,
                                 java.time.Instant createdAt, java.time.Instant updatedAt, Long version) {
        Role r = new Role();
        r.id = id;
        r.name = name;
        r.description = description;
        r.permissionCodes = permissionCodes == null ? Set.of() : Set.copyOf(permissionCodes);
        r.createdAt = createdAt;
        r.updatedAt = updatedAt;
        r.version = version;
        return r;
    }

    public String getName() { return name; }
    public String getDescription() { return description; }
    public Set<String> getPermissionCodes() { return Collections.unmodifiableSet(permissionCodes); }

    public boolean hasPermission(String code) {
        return permissionCodes.contains(code);
    }
}
