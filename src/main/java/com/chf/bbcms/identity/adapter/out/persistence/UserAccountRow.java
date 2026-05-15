package com.chf.bbcms.identity.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Table("bbcms_user_account")
public class UserAccountRow {
    @Id private UUID id;
    private String email;
    @Column("password_hash") private String passwordHash;
    private String phone;
    private String status;
    @Column("user_type")     private String userType;
    @Column("last_login_at") private Instant lastLoginAt;
    private String locale;

    @Column("first_names")    private String firstNames;
    @Column("next_names")     private String nextNames;
    @Column("date_of_birth")  private LocalDate dateOfBirth;
    private String gender;
    @Column("date_born_again") private LocalDate dateBornAgain;
    @Column("how_born_again")  private String howBornAgain;
    @Column("date_entered")    private LocalDate dateEntered;
    @Column("picture_file_id") private UUID pictureFileId;

    @Column("anonymized_at")  private Instant anonymizedAt;

    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
    public Instant getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(Instant lastLoginAt) { this.lastLoginAt = lastLoginAt; }
    public String getLocale() { return locale; }
    public void setLocale(String locale) { this.locale = locale; }
    public String getFirstNames() { return firstNames; }
    public void setFirstNames(String firstNames) { this.firstNames = firstNames; }
    public String getNextNames() { return nextNames; }
    public void setNextNames(String nextNames) { this.nextNames = nextNames; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public LocalDate getDateBornAgain() { return dateBornAgain; }
    public void setDateBornAgain(LocalDate dateBornAgain) { this.dateBornAgain = dateBornAgain; }
    public String getHowBornAgain() { return howBornAgain; }
    public void setHowBornAgain(String howBornAgain) { this.howBornAgain = howBornAgain; }
    public LocalDate getDateEntered() { return dateEntered; }
    public void setDateEntered(LocalDate dateEntered) { this.dateEntered = dateEntered; }
    public UUID getPictureFileId() { return pictureFileId; }
    public void setPictureFileId(UUID pictureFileId) { this.pictureFileId = pictureFileId; }
    public Instant getAnonymizedAt() { return anonymizedAt; }
    public void setAnonymizedAt(Instant anonymizedAt) { this.anonymizedAt = anonymizedAt; }
    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public UUID getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(UUID updatedBy) { this.updatedBy = updatedBy; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
    public Long getVersion() { return version; }
    public void setVersion(Long version) { this.version = version; }
}
