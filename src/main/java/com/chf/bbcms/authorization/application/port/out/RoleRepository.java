package com.chf.bbcms.authorization.application.port.out;

import com.chf.bbcms.authorization.domain.Role;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface RoleRepository {
    Mono<Role> findById(UUID id);
    Mono<Role> findByName(String name);
    Flux<Role> findAll();
    Flux<Role> findByIds(Iterable<UUID> ids);
}
