package com.chf.bbcms.attendance.domain;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AcademicYearsTest {

    @Test
    void september_starts_new_academic_year() {
        assertEquals(2025, AcademicYears.of(LocalDate.of(2025, 9, 1)));
        assertEquals(2025, AcademicYears.of(LocalDate.of(2025, 12, 31)));
    }

    @Test
    void august_belongs_to_previous_academic_year() {
        assertEquals(2024, AcademicYears.of(LocalDate.of(2025, 1, 15)));
        assertEquals(2024, AcademicYears.of(LocalDate.of(2025, 8, 31)));
    }
}
