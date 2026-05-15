package com.chf.bbcms.attendance.domain;

import java.time.LocalDate;

/**
 * Convention année académique CHF: démarre le 1er septembre.
 * academicYear(2025-09-01) = 2025
 * academicYear(2026-08-31) = 2025
 */
public final class AcademicYears {

    private AcademicYears() {}

    public static int of(LocalDate date) {
        return date.getMonthValue() >= 9 ? date.getYear() : date.getYear() - 1;
    }

    public static int current() { return of(LocalDate.now()); }
}
