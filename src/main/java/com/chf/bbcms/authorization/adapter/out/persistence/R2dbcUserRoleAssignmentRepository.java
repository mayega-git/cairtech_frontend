package com.chf.bbcms.authorization.adapter.out.persistence;

import com.chf.bbcms.authorization.application.port.out.UserRoleAssignmentRepository;
import com.chf.bbcms.authorization.domain.UserRoleAssignment;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import org.springframework.data.relational.core.query.Criteria;
import org.springframework.data.relational.core.query.Query;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.UUID;

@Repository
public class R2dbcUserRoleAssignmentRepository implements UserRoleAssignmentRepository {

    private final R2dbcEntityTemplate template;

    public R2dbcUserRoleAssignmentRepository(R2dbcEntityTemplate template) {
        this.template = template;
    }

    @Override
    public Flux<UserRoleAssignment> findActiveByUser(UUID userAccountId) {
        return template.select(UserRoleAssignmentRow.class)
                .matching(Query.query(Criteria.where("user_account_id").is(userAccountId)
                        .and("active").isTrue()))
                .all()
                .map(this::toDomain);
    }

    private UserRoleAssignment toDomain(UserRoleAssignmentRow row) {
        try {
            // Le constructeur sans-arg de l'agrégat est `protected` (pattern hexagonal :
            // l'instanciation passe normalement par une factory statique du domaine).
            // Pour la rehydratation depuis la BD, on l'ouvre via setAccessible(true).
            Constructor<UserRoleAssignment> ctor =
                    UserRoleAssignment.class.getDeclaredConstructor();
            ctor.setAccessible(true);
            UserRoleAssignment ura = ctor.newInstance();
            setField(ura, "id", row.getId());
            setField(ura, "userAccountId", row.getUserAccountId());
            setField(ura, "roleId", row.getRoleId());
            setField(ura, "scopeBibleClubId", row.getScopeBibleClubId());
            setField(ura, "active", row.isActive());
            return ura;
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException("Cannot instantiate UserRoleAssignment", e);
        }
    }

    private static void setField(Object target, String name, Object value) throws ReflectiveOperationException {
        Class<?> c = target.getClass();
        while (c != null) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                f.set(target, value);
                return;
            } catch (NoSuchFieldException ignored) {
                c = c.getSuperclass();
            }
        }
        throw new NoSuchFieldException(name);
    }
}
