package com.chf.bbcms.people.domain;

import com.chf.bbcms.shared.domain.BusinessRuleViolation;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class MemberTest {

    @Test
    void newStudent_requires_bbc_and_level() {
        UUID u = UUID.randomUUID();
        assertThrows(IllegalArgumentException.class,
                () -> Member.newStudent(u, null, UUID.randomUUID()));
        assertThrows(IllegalArgumentException.class,
                () -> Member.newStudent(u, UUID.randomUUID(), null));
    }

    @Test
    void newStudent_initializes_active_with_zero_score() {
        Member m = Member.newStudent(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
        assertEquals(MemberKind.STUDENT, m.getKind());
        assertEquals(MemberStatus.ACTIVE, m.getStatus());
        assertEquals(0, m.getParticipationScore());
    }

    @Test
    void newProfessional_requires_profession() {
        assertThrows(IllegalArgumentException.class,
                () -> Member.newProfessional(UUID.randomUUID(), "  ", ProfessionalPosition.SIMPLE_PROFESSIONAL));
    }

    @Test
    void mentor_kind_inferred_from_position() {
        Member m = Member.newProfessional(UUID.randomUUID(), "Dev", ProfessionalPosition.MENTOR);
        assertEquals(MemberKind.MENTOR, m.getKind());
    }

    @Test
    void incrementScore_only_for_student() {
        Member pro = Member.newProfessional(UUID.randomUUID(), "Dev", ProfessionalPosition.SIMPLE_PROFESSIONAL);
        BusinessRuleViolation ex = assertThrows(BusinessRuleViolation.class, () -> pro.incrementScore(1));
        assertEquals("BBCMS_NOT_STUDENT", ex.getCode());
    }

    @Test
    void student_score_increments() {
        Member s = Member.newStudent(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
        s.incrementScore(1);
        s.incrementScore(2);
        assertEquals(3, s.getParticipationScore());
    }

    @Test
    void departments_can_be_added_and_removed() {
        Member s = Member.newStudent(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
        s.addDepartment(Department.INTERCESSOR);
        s.addDepartment(Department.CHARIS);
        assertEquals(2, s.getDepartments().size());
        s.removeDepartment(Department.INTERCESSOR);
        assertEquals(1, s.getDepartments().size());
        assertTrue(s.getDepartments().contains(Department.CHARIS));
    }

    @Test
    void transferLevel_only_for_student() {
        Member nl = Member.newNationalLeader(UUID.randomUUID(), "Pasteur");
        assertThrows(BusinessRuleViolation.class, () -> nl.transferLevel(UUID.randomUUID()));
    }

    @Test
    void transferLevel_changes_levelId() {
        Member s = Member.newStudent(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
        UUID newLevel = UUID.randomUUID();
        s.transferLevel(newLevel);
        assertEquals(newLevel, s.getLevelId().orElseThrow());
    }

    @Test
    void leave_marks_removed() {
        Member s = Member.newStudent(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
        s.leave();
        assertEquals(MemberStatus.REMOVED, s.getStatus());
    }
}
