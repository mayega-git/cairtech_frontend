package com.chf.bbcms.people.application.port.in;

import com.chf.bbcms.people.domain.Department;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

/**
 * Vue UI d'un Member enrichie des données du UserAccount associé
 * (PII centralisées côté UserAccount comme décidé dans le cahier).
 *
 * Utilisée par les écrans Annuaire et Fiche membre — évite N+1 côté frontend.
 */
public record MemberWithProfile(
        UUID memberId,
        UUID userAccountId,
        String kind,
        UUID bibleClubId,
        UUID levelId,
        int participationScore,
        BigDecimal faithfulPercentage,
        String profession,
        String professionalPosition,
        String memberStatus,
        Set<Department> departments,
        // UserAccount fields
        String email,
        String firstNames,
        String nextNames,
        String gender,
        LocalDate dateOfBirth,
        UUID pictureFileId,
        String accountStatus,
        String userType
) {}
