package com.chf.bbcms.authorization.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.util.Optional;
import java.util.UUID;

/**
 * Affectation d'un rôle à un utilisateur, optionnellement scopée à un Bible Club.
 * scope_bible_club_id = null → permission globale (typiquement NATIONAL_LEADER, SYSTEM_ADMIN).
 */
public class UserRoleAssignment extends BaseEntity {

    private UUID userAccountId;
    private UUID roleId;
    private UUID scopeBibleClubId;
    private boolean active;

    protected UserRoleAssignment() {}

    public UUID getUserAccountId() { return userAccountId; }
    public UUID getRoleId() { return roleId; }
    public Optional<UUID> getScopeBibleClubId() { return Optional.ofNullable(scopeBibleClubId); }
    public boolean isActive() { return active; }

    public boolean appliesTo(UUID bibleClubId) {
        if (!active) return false;
        if (scopeBibleClubId == null) return true; // global
        return scopeBibleClubId.equals(bibleClubId);
    }
}
