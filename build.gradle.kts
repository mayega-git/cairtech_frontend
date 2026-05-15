plugins {
    java
    id("org.springframework.boot") version "3.3.5"
    id("io.spring.dependency-management") version "1.1.6"
}

group = "com.chf"
version = "0.1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

extra["testcontainersVersion"] = "1.20.3"
extra["springdocVersion"] = "2.6.0"
extra["jjwtVersion"] = "0.12.6"
extra["minioVersion"] = "8.5.13"
extra["shedlockVersion"] = "5.16.0"
extra["caffeineVersion"] = "3.1.8"
extra["mapstructVersion"] = "1.6.2"
extra["archunitVersion"] = "1.3.0"
extra["openpdfVersion"] = "2.0.3"
extra["dotenvVersion"] = "4.0.0"

dependencies {
    // Spring Boot WebFlux + Security + R2DBC
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-data-r2dbc")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-mail")

    // PostgreSQL R2DBC + JDBC (JDBC pour Liquibase + ShedLock)
    implementation("org.postgresql:r2dbc-postgresql")
    runtimeOnly("org.postgresql:postgresql")
    implementation("org.springframework.boot:spring-boot-starter-jdbc")

    // Liquibase
    implementation("org.liquibase:liquibase-core")

    // ShedLock (scheduler distribué) — DB lock provider
    implementation("net.javacrumbs.shedlock:shedlock-spring:${property("shedlockVersion")}")
    implementation("net.javacrumbs.shedlock:shedlock-provider-jdbc-template:${property("shedlockVersion")}")

    // JWT (jjwt)
    implementation("io.jsonwebtoken:jjwt-api:${property("jjwtVersion")}")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:${property("jjwtVersion")}")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:${property("jjwtVersion")}")

    // MinIO
    implementation("io.minio:minio:${property("minioVersion")}")

    // Cache (Caffeine)
    implementation("com.github.ben-manes.caffeine:caffeine:${property("caffeineVersion")}")

    // OpenAPI
    implementation("org.springdoc:springdoc-openapi-starter-webflux-ui:${property("springdocVersion")}")

    // OpenPDF (LGPL fork of iText 2.x) — génération PDF des snapshots reset
    implementation("com.github.librepdf:openpdf:${property("openpdfVersion")}")

    // .env loader (intégration Spring Boot via PropertySource)
    implementation("me.paulschwarz:spring-dotenv:${property("dotenvVersion")}")

    // MapStruct
    implementation("org.mapstruct:mapstruct:${property("mapstructVersion")}")
    annotationProcessor("org.mapstruct:mapstruct-processor:${property("mapstructVersion")}")

    // Observabilité
    implementation("io.micrometer:micrometer-registry-prometheus")

    // Tests
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }
    testImplementation("io.projectreactor:reactor-test")
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation("com.tngtech.archunit:archunit-junit5:${property("archunitVersion")}")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("org.testcontainers:r2dbc")
    testImplementation("org.testcontainers:minio")
}

dependencyManagement {
    imports {
        mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf("-parameters", "-Xlint:unchecked"))
}
