package com.chf.bbcms.identity.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public class MembershipRequest extends BaseEntity {

    private UUID userAccountId;
    private UserType requestedType;
    private UUID bibleClubId;
    private UUID levelId;
    private String profession;
    private MembershipRequestStatus status;
    private UUID decisionBy;
    private Instant decisionAt;
    private String decisionComment;

    protected MembershipRequest() {}

    public static MembershipRequest submit(UUID userAccountId, UserType requestedType,
                                           UUID bibleClubId, UUID levelId, String profession) {
        if (userAccountId == null) throw new IllegalArgumentException("userAccountId is required");
        if (requestedType == null) throw new IllegalArgumentException("requestedType is required");
        if (requestedType == UserType.VISITOR)
            throw new BusinessRuleViolation("BBCMS_REQUEST_INVALID_TYPE",
                    "VISITOR is the default user type and cannot be requested via MembershipRequest");
        if (requestedType == UserType.STUDENT && (bibleClubId == null || levelId == null))
            throw new BusinessRuleViolation("BBCMS_REQUEST_INCOMPLETE",
                    "STUDENT requests must include bibleClubId and levelId");
        if (requestedType == UserType.PROFESSIONAL && (profession == null || profession.isBlank()))
            throw new BusinessRuleViolation("BBCMS_REQUEST_INCOMPLETE",
                    "PROFESSIONAL requests must include profession");
        MembershipRequest r = new MembershipRequest();
        r.userAccountId = userAccountId;
        r.requestedType = requestedType;
        r.bibleClubId = bibleClubId;
        r.levelId = levelId;
        r.profession = profession;
        r.status = MembershipRequestStatus.PENDING;
        return r;
    }

    public static MembershipRequest rehydrate(UUID id, UUID userAccountId, UserType requestedType,
                                              UUID bibleClubId, UUID levelId, String profession,
                                              MembershipRequestStatus status, UUID decisionBy,
                                              Instant decisionAt, String decisionComment,
                                              Instant createdAt, Instant updatedAt, Long version) {
        MembershipRequest r = new MembershipRequest();
        r.id = id;
        r.userAccountId = userAccountId;
        r.requestedType = requestedType;
        r.bibleClubId = bibleClubId;
        r.levelId = levelId;
        r.profession = profession;
        r.status = status;
        r.decisionBy = decisionBy;
        r.decisionAt = decisionAt;
        r.decisionComment = decisionComment;
        r.createdAt = createdAt;
        r.updatedAt = updatedAt;
        r.version = version;
        return r;
    }

    public void approve(UUID by, UUID assignedBibleClubId, UUID assignedLevelId, String comment) {
        ensurePending();
        this.status = MembershipRequestStatus.APPROVED;
        this.decisionBy = by;
        this.decisionAt = Instant.now();
        this.decisionComment = comment;
        if (assignedBibleClubId != null) this.bibleClubId = assignedBibleClubId;
        if (assignedLevelId != null) this.levelId = assignedLevelId;
    }

    public void reject(UUID by, String comment) {
        ensurePending();
        this.status = MembershipRequestStatus.REJECTED;
        this.decisionBy = by;
        this.decisionAt = Instant.now();
        this.decisionComment = comment;
    }

    public void cancel() {
        ensurePending();
        this.status = MembershipRequestStatus.CANCELLED;
        this.decisionAt = Instant.now();
    }

    private void ensurePending() {
        if (status != MembershipRequestStatus.PENDING)
            throw new BusinessRuleViolation("BBCMS_REQUEST_NOT_PENDING",
                    "MembershipRequest is not pending (current=" + status + ")");
    }

    public UUID getUserAccountId() { return userAccountId; }
    public UserType getRequestedType() { return requestedType; }
    public Optional<UUID> getBibleClubId() { return Optional.ofNullable(bibleClubId); }
    public Optional<UUID> getLevelId() { return Optional.ofNullable(levelId); }
    public String getProfession() { return profession; }
    public MembershipRequestStatus getStatus() { return status; }
    public UUID getDecisionBy() { return decisionBy; }
    public Instant getDecisionAt() { return decisionAt; }
    public String getDecisionComment() { return decisionComment; }
}
