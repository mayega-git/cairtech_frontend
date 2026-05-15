package com.chf.bbcms.authorization.adapter.out.persistence;

import com.chf.bbcms.authorization.application.port.out.RoleRepository;
import com.chf.bbcms.authorization.domain.Role;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.HashSet;
import java.util.List;
import java.util.UUID;

@Repository
public class R2dbcRoleRepository implements RoleRepository {

    private final DatabaseClient client;

    public R2dbcRoleRepository(DatabaseClient client) {
        this.client = client;
    }

    @Override
    public Mono<Role> findById(UUID id) {
        return loadRole("SELECT r.* FROM bbcms_role r WHERE r.id = :id", "id", id).next();
    }

    @Override
    public Mono<Role> findByName(String name) {
        return loadRole("SELECT r.* FROM bbcms_role r WHERE r.name = :name", "name", name).next();
    }

    @Override
    public Flux<Role> findAll() {
        return loadRole("SELECT r.* FROM bbcms_role r ORDER BY r.name", null, null);
    }

    @Override
    public Flux<Role> findByIds(Iterable<UUID> ids) {
        var idList = java.util.stream.StreamSupport.stream(ids.spliterator(), false).toList();
        if (idList.isEmpty()) return Flux.empty();
        return client.sql("SELECT r.* FROM bbcms_role r WHERE r.id IN (:ids)")
                .bind("ids", idList)
                .map((row, meta) -> mapBase(row))
                .all()
                .flatMap(this::attachPermissions);
    }

    private Flux<Role> loadRole(String sql, String paramName, Object value) {
        var spec = client.sql(sql).map((row, meta) -> mapBase(row));
        var bound = paramName != null ? client.sql(sql).bind(paramName, value).map((r, m) -> mapBase(r)) : spec;
        return bound.all().flatMap(this::attachPermissions);
    }

    private Mono<Role> attachPermissions(RoleStub stub) {
        return client.sql("SELECT permission_code FROM bbcms_role_permission WHERE role_id = :rid")
                .bind("rid", stub.id)
                .map((row, m) -> row.get("permission_code", String.class))
                .all()
                .collect(HashSet<String>::new, HashSet::add)
                .map(perms -> Role.rehydrate(stub.id, stub.name, stub.description, perms,
                        stub.createdAt, stub.updatedAt, stub.version));
    }

    private RoleStub mapBase(io.r2dbc.spi.Row row) {
        return new RoleStub(
                row.get("id", UUID.class),
                row.get("name", String.class),
                row.get("description", String.class),
                row.get("created_at", java.time.Instant.class),
                row.get("updated_at", java.time.Instant.class),
                row.get("version", Long.class)
        );
    }

    private record RoleStub(UUID id, String name, String description,
                            java.time.Instant createdAt, java.time.Instant updatedAt, Long version) {}
}
