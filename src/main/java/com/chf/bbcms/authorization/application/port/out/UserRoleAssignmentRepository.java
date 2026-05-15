package com.chf.bbcms.authorization.application.port.out;

import com.chf.bbcms.authorization.domain.UserRoleAssignment;
import reactor.core.publisher.Flux;

import java.util.UUID;

public interface UserRoleAssignmentRepository {
    Flux<UserRoleAssignment> findActiveByUser(UUID userAccountId);
}
