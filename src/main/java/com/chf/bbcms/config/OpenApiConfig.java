package com.chf.bbcms.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI bbcmsOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("BBCMS API")
                        .description("Bible Club Management System — backend API. "
                                + "Architecture hexagonale, Spring Boot WebFlux, R2DBC.")
                        .version("v1")
                        .license(new License().name("Internal CHF").url("https://chf.org"))
                        .contact(new Contact().name("Équipe technique CHF")))
                .servers(List.of(new Server().url("/").description("Local")))
                .addSecurityItem(new SecurityRequirement().addList("BearerAuth"))
                .components(new Components()
                        .addSecuritySchemes("BearerAuth", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT HS256 émis par /api/v1/bbcms/auth/login")));
    }
}
