package com.chf.bbcms.organization.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class BibleClub extends BaseEntity {

    private String name;
    private String profile;
    private String schoolName;
    private Integer goalNbFaithful;
    private LocalDate dateCreated;
    private BibleClubStatus status;
    private UUID presidentMemberId;
    private UUID vicePresidentMemberId;
    private UUID secretaryMemberId;
    private UUID imageFileId;

    protected BibleClub() {}

    public static BibleClub create(String name, String profile, String schoolName,
                                   Integer goalNbFaithful, LocalDate dateCreated) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("BibleClub.name is required");
        }
        BibleClub b = new BibleClub();
        b.name = name;
        b.profile = profile;
        b.schoolName = schoolName;
        b.goalNbFaithful = goalNbFaithful;
        b.dateCreated = dateCreated == null ? LocalDate.now() : dateCreated;
        b.status = BibleClubStatus.ACTIVE;
        return b;
    }

    public static BibleClub rehydrate(UUID id, String name, String profile, String schoolName,
                                      Integer goalNbFaithful, LocalDate dateCreated, BibleClubStatus status,
                                      UUID presidentMemberId, UUID vicePresidentMemberId, UUID secretaryMemberId,
                                      UUID imageFileId,
                                      Instant createdAt, Instant updatedAt, Long version) {
        BibleClub b = new BibleClub();
        b.id = id;
        b.name = name;
        b.profile = profile;
        b.schoolName = schoolName;
        b.goalNbFaithful = goalNbFaithful;
        b.dateCreated = dateCreated;
        b.status = status;
        b.presidentMemberId = presidentMemberId;
        b.vicePresidentMemberId = vicePresidentMemberId;
        b.secretaryMemberId = secretaryMemberId;
        b.imageFileId = imageFileId;
        b.createdAt = createdAt;
        b.updatedAt = updatedAt;
        b.version = version;
        return b;
    }

    public void setGoalNbFaithful(int goal) {
        ensureMutable();
        if (goal < 0) throw new IllegalArgumentException("goalNbFaithful must be >= 0");
        this.goalNbFaithful = goal;
    }

    public void rename(String newName) {
        ensureMutable();
        if (newName == null || newName.isBlank())
            throw new IllegalArgumentException("name cannot be blank");
        this.name = newName;
    }

    public void assignPresident(UUID memberId)      { ensureMutable(); this.presidentMemberId = memberId; }
    public void assignVicePresident(UUID memberId)  { ensureMutable(); this.vicePresidentMemberId = memberId; }
    public void assignSecretary(UUID memberId)      { ensureMutable(); this.secretaryMemberId = memberId; }
    public void setImageFileId(UUID imageFileId)    { ensureMutable(); this.imageFileId = imageFileId; }

    public void startReset() {
        if (status != BibleClubStatus.ACTIVE)
            throw new BusinessRuleViolation("BBCMS_BBC_NOT_ACTIVE",
                    "Only ACTIVE BBC can be reset (current=%s)".formatted(status));
        this.status = BibleClubStatus.UNDER_RESET;
    }

    public void finishReset() {
        if (status != BibleClubStatus.UNDER_RESET)
            throw new BusinessRuleViolation("BBCMS_BBC_NOT_RESETTING",
                    "BBC is not in UNDER_RESET state");
        this.status = BibleClubStatus.ACTIVE;
    }

    public void archive() { this.status = BibleClubStatus.ARCHIVED; }

    private void ensureMutable() {
        if (status == BibleClubStatus.UNDER_RESET)
            throw new BusinessRuleViolation("BBCMS_BBC_FROZEN",
                    "Writes are frozen while BBC is UNDER_RESET (RM-07)");
        if (status == BibleClubStatus.ARCHIVED)
            throw new BusinessRuleViolation("BBCMS_BBC_ARCHIVED",
                    "Cannot mutate an ARCHIVED BBC");
    }

    public String getName() { return name; }
    public String getProfile() { return profile; }
    public String getSchoolName() { return schoolName; }
    public Integer getGoalNbFaithful() { return goalNbFaithful; }
    public LocalDate getDateCreated() { return dateCreated; }
    public BibleClubStatus getStatus() { return status; }
    public UUID getPresidentMemberId() { return presidentMemberId; }
    public UUID getVicePresidentMemberId() { return vicePresidentMemberId; }
    public UUID getSecretaryMemberId() { return secretaryMemberId; }
    public UUID getImageFileId() { return imageFileId; }
}
