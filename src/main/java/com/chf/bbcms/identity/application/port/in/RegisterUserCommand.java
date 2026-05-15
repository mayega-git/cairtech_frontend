package com.chf.bbcms.identity.application.port.in;

import com.chf.bbcms.identity.domain.Gender;
import com.chf.bbcms.identity.domain.UserType;

import java.time.LocalDate;
import java.util.UUID;

public record RegisterUserCommand(
        String email,
        String plainPassword,
        String phone,
        String firstNames,
        String nextNames,
        LocalDate dateOfBirth,
        Gender gender,
        String locale,
        UserType requestedType,
        UUID bibleClubId,
        UUID levelId,
        String profession
) {}
