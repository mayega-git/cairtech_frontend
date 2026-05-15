package com.chf.bbcms.people.domain;

import com.chf.bbcms.shared.domain.BaseEntity;
import com.chf.bbcms.shared.domain.BusinessRuleViolation;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * Agrégat polymorphe (single-table) pour Student / Professional / Mentor / NationalLeader.
 *
 * <p>Décision validée: les PII (firstNames, gender, dateOfBirth, picture, ...) ne sont
 * PAS dupliquées ici. Elles sont lues via {@link #userAccountId} → bbcms_user_account.</p>
 *
 * <p>Les champs spécifiques sont nullables selon le {@link MemberKind}:
 * <ul>
 *   <li>STUDENT: bibleClubId, levelId, participationScore, faithfulPercentage</li>
 *   <li>PROFESSIONAL/MENTOR: profession, professionalPosition</li>
 *   <li>NATIONAL_LEADER: profession (optionnel)</li>
 * </ul></p>
 */
public class Member extends BaseEntity {

    private UUID userAccountId;
    private MemberKind kind;
    private UUID bibleClubId;
    private UUID levelId;
    private int participationScore;
    private BigDecimal faithfulPercentage;
    private String profession;
    private ProfessionalPosition professionalPosition;
    private MemberStatus status;
    private Set<Department> departments = new HashSet<>();

    protected Member() {}

    public static Member newStudent(UUID userAccountId, UUID bibleClubId, UUID levelId) {
        if (userAccountId == null) throw new IllegalArgumentException("userAccountId is required");
        if (bibleClubId == null) throw new IllegalArgumentException("STUDENT must have a bibleClubId");
        if (levelId == null) throw new IllegalArgumentException("STUDENT must have a levelId");
        Member m = new Member();
        m.userAccountId = userAccountId;
        m.kind = MemberKind.STUDENT;
        m.bibleClubId = bibleClubId;
        m.levelId = levelId;
        m.participationScore = 0;
        m.faithfulPercentage = BigDecimal.ZERO;
        m.status = MemberStatus.ACTIVE;
        return m;
    }

    public static Member newProfessional(UUID userAccountId, String profession,
                                         ProfessionalPosition position) {
        if (userAccountId == null) throw new IllegalArgumentException("userAccountId is required");
        if (profession == null || profession.isBlank()) throw new IllegalArgumentException("profession is required");
        Member m = new Member();
        m.userAccountId = userAccountId;
        m.kind = position == ProfessionalPosition.MENTOR ? MemberKind.MENTOR : MemberKind.PROFESSIONAL;
        m.profession = profession;
        m.professionalPosition = position == null ? ProfessionalPosition.SIMPLE_PROFESSIONAL : position;
        m.status = MemberStatus.ACTIVE;
        return m;
    }

    public static Member newNationalLeader(UUID userAccountId, String profession) {
        if (userAccountId == null) throw new IllegalArgumentException("userAccountId is required");
        Member m = new Member();
        m.userAccountId = userAccountId;
        m.kind = MemberKind.NATIONAL_LEADER;
        m.profession = profession;
        m.status = MemberStatus.ACTIVE;
        return m;
    }

    public static Member rehydrate(UUID id, UUID userAccountId, MemberKind kind,
                                   UUID bibleClubId, UUID levelId,
                                   int participationScore, BigDecimal faithfulPercentage,
                                   String profession, ProfessionalPosition professionalPosition,
                                   MemberStatus status, Set<Department> departments,
                                   Instant createdAt, Instant updatedAt, Long version) {
        Member m = new Member();
        m.id = id;
        m.userAccountId = userAccountId;
        m.kind = kind;
        m.bibleClubId = bibleClubId;
        m.levelId = levelId;
        m.participationScore = participationScore;
        m.faithfulPercentage = faithfulPercentage;
        m.profession = profession;
        m.professionalPosition = professionalPosition;
        m.status = status;
        m.departments = departments == null ? new HashSet<>() : new HashSet<>(departments);
        m.createdAt = createdAt;
        m.updatedAt = updatedAt;
        m.version = version;
        return m;
    }

    public void transferLevel(UUID newLevelId) {
        ensureKind(MemberKind.STUDENT, "BBCMS_NOT_STUDENT", "Only students can change level");
        if (newLevelId == null) throw new IllegalArgumentException("newLevelId is required");
        this.levelId = newLevelId;
    }

    public void transferBibleClub(UUID newBibleClubId, UUID newLevelId) {
        ensureKind(MemberKind.STUDENT, "BBCMS_NOT_STUDENT", "Only students can change BBC");
        this.bibleClubId = newBibleClubId;
        this.levelId = newLevelId;
    }

    public void incrementScore(int weight) {
        ensureKind(MemberKind.STUDENT, "BBCMS_NOT_STUDENT", "Only students have a participation score");
        if (weight < 0) throw new IllegalArgumentException("weight must be >= 0");
        this.participationScore += weight;
    }

    public void resetScore() {
        this.participationScore = 0;
        this.faithfulPercentage = BigDecimal.ZERO;
    }

    public void setFaithfulPercentage(BigDecimal pct) {
        this.faithfulPercentage = pct == null ? BigDecimal.ZERO : pct;
    }

    public void addDepartment(Department d) {
        if (d == null) throw new IllegalArgumentException("department is required");
        this.departments.add(d);
    }

    public void removeDepartment(Department d) { this.departments.remove(d); }

    public void markInactive() {
        if (status == MemberStatus.REMOVED || status == MemberStatus.TRANSFERRED)
            throw new BusinessRuleViolation("BBCMS_MEMBER_FROZEN",
                    "Cannot mark INACTIVE a %s member".formatted(status));
        this.status = MemberStatus.INACTIVE;
    }

    public void markActive() {
        if (status == MemberStatus.REMOVED || status == MemberStatus.TRANSFERRED)
            throw new BusinessRuleViolation("BBCMS_MEMBER_FROZEN",
                    "Cannot mark ACTIVE a %s member".formatted(status));
        this.status = MemberStatus.ACTIVE;
    }

    public void leave() { this.status = MemberStatus.REMOVED; }
    public void markTransferred() { this.status = MemberStatus.TRANSFERRED; }

    public boolean isStudent() { return kind == MemberKind.STUDENT; }
    public boolean isMentor()  { return kind == MemberKind.MENTOR; }

    private void ensureKind(MemberKind expected, String code, String message) {
        if (kind != expected) throw new BusinessRuleViolation(code, message);
    }

    public UUID getUserAccountId() { return userAccountId; }
    public MemberKind getKind() { return kind; }
    public Optional<UUID> getBibleClubId() { return Optional.ofNullable(bibleClubId); }
    public Optional<UUID> getLevelId() { return Optional.ofNullable(levelId); }
    public int getParticipationScore() { return participationScore; }
    public BigDecimal getFaithfulPercentage() { return faithfulPercentage; }
    public String getProfession() { return profession; }
    public ProfessionalPosition getProfessionalPosition() { return professionalPosition; }
    public MemberStatus getStatus() { return status; }
    public Set<Department> getDepartments() { return Set.copyOf(departments); }
}
