package com.chf.bbcms.authorization.application.service;

import com.chf.bbcms.authorization.application.port.out.RoleRepository;
import com.chf.bbcms.authorization.application.port.out.UserRoleAssignmentRepository;
import com.chf.bbcms.authorization.domain.Role;
import com.chf.bbcms.authorization.domain.UserRoleAssignment;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * Calcule les permissions effectives d'un utilisateur en croisant
 * ses UserRoleAssignment actifs avec leurs Role/permissions.
 * Le scope_bible_club_id est appliqué au moment de la vérification (PermissionEvaluator).
 */
@Service
public class AuthorizationService {

    private final UserRoleAssignmentRepository assignmentRepository;
    private final RoleRepository roleRepository;

    public AuthorizationService(UserRoleAssignmentRepository assignmentRepository,
                                RoleRepository roleRepository) {
        this.assignmentRepository = assignmentRepository;
        this.roleRepository = roleRepository;
    }

    /**
     * Toutes les permissions effectives, sans considération de scope.
     * Utilisé pour pré-charger dans le JWT.
     */
    public Mono<Set<String>> permissionsOf(UUID userAccountId) {
        return assignmentRepository.findActiveByUser(userAccountId)
                .map(UserRoleAssignment::getRoleId)
                .collectList()
                .flatMapMany(roleRepository::findByIds)
                .map(Role::getPermissionCodes)
                .reduce(new HashSet<String>(), (acc, perms) -> {
                    acc.addAll(perms);
                    return acc;
                })
                .map(set -> (Set<String>) Set.copyOf(set));
    }
}
