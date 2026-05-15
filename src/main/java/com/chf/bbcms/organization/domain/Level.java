package com.chf.bbcms.organization.domain;

import com.chf.bbcms.shared.domain.BaseEntity;

import java.time.Instant;
import java.util.UUID;

public class Level extends BaseEntity {

    private UUID bibleClubId;
    private String name;
    private String profile;
    private LevelType type;
    private UUID presidentMemberId;
    private UUID vicePresidentMemberId;

    protected Level() {}

    public static Level create(UUID bibleClubId, String name, String profile, LevelType type) {
        if (bibleClubId == null) throw new IllegalArgumentException("bibleClubId is required");
        if (type == null) throw new IllegalArgumentException("type is required");
        if (name == null || name.isBlank()) throw new IllegalArgumentException("name is required");
        Level l = new Level();
        l.bibleClubId = bibleClubId;
        l.name = name;
        l.profile = profile;
        l.type = type;
        return l;
    }

    public static Level rehydrate(UUID id, UUID bibleClubId, String name, String profile,
                                  LevelType type, UUID presidentMemberId, UUID vicePresidentMemberId,
                                  Instant createdAt, Instant updatedAt, Long version) {
        Level l = new Level();
        l.id = id;
        l.bibleClubId = bibleClubId;
        l.name = name;
        l.profile = profile;
        l.type = type;
        l.presidentMemberId = presidentMemberId;
        l.vicePresidentMemberId = vicePresidentMemberId;
        l.createdAt = createdAt;
        l.updatedAt = updatedAt;
        l.version = version;
        return l;
    }

    public void rename(String newName) {
        if (newName == null || newName.isBlank()) throw new IllegalArgumentException("name cannot be blank");
        this.name = newName;
    }

    public void assignPresident(UUID memberId) { this.presidentMemberId = memberId; }
    public void assignVicePresident(UUID memberId) { this.vicePresidentMemberId = memberId; }

    public UUID getBibleClubId() { return bibleClubId; }
    public String getName() { return name; }
    public String getProfile() { return profile; }
    public LevelType getType() { return type; }
    public UUID getPresidentMemberId() { return presidentMemberId; }
    public UUID getVicePresidentMemberId() { return vicePresidentMemberId; }
}
