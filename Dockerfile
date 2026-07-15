# syntax=docker/dockerfile:1.7
#
# Build unique frontend + backend — BBCMS
# ----------------------------------------
# Stage 1 compile le frontend Flutter en application web statique.
# Stage 2 embarque ce build dans les ressources statiques Spring (classpath:/static/)
#         puis compile le backend en un seul jar exécutable (bootJar).
# Stage 3 est l'image d'exécution finale : un seul processus JVM sert l'API
#         (/api/v1/bbcms/**) ET l'UI web (/) sur le même port, même origine
#         (pas de CORS, pas de reverse-proxy nécessaire).

########################################
# 1. Frontend build (Flutter Web)
########################################
FROM ghcr.io/cirruslabs/flutter:stable AS frontend-build
WORKDIR /app/mobile

# Cache des dépendances pub tant que pubspec ne change pas
COPY mobile/pubspec.yaml mobile/pubspec.lock ./
RUN flutter pub get

COPY mobile/ .

# API_BASE_URL vide => les appels Dio sont relatifs à l'origine qui sert
# index.html. En prod (single container) c'est le même serveur Spring,
# donc pas besoin de coder une URL en dur au build.
ARG API_BASE_URL=""
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

########################################
# 2. Backend build (Spring Boot / Gradle)
########################################
FROM eclipse-temurin:21-jdk-jammy AS backend-build
WORKDIR /app

# Cache du wrapper/dépendances Gradle tant que les fichiers de build ne changent pas
COPY gradlew build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
RUN --mount=type=cache,target=/root/.gradle ./gradlew --version

COPY src ./src

# Le frontend compilé devient les ressources statiques du jar Spring
COPY --from=frontend-build /app/mobile/build/web ./src/main/resources/static

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew bootJar --no-daemon -x test

########################################
# 3. Runtime (JVM only, image finale)
########################################
FROM eclipse-temurin:21-jre-jammy AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --no-create-home --shell /usr/sbin/nologin bbcms

WORKDIR /app
COPY --from=backend-build /app/build/libs/*.jar app.jar
RUN chown bbcms:bbcms app.jar
USER bbcms

ENV JAVA_OPTS=""
EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=40s --retries=5 \
    CMD curl -fs http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "\
    if [ -n \"$BBCMS_DB_HOST\" ]; then \
      export BBCMS_R2DBC_URL=\"r2dbc:postgresql://${BBCMS_DB_HOST}:${BBCMS_DB_PORT}/${BBCMS_DB_NAME}\"; \
      export BBCMS_JDBC_URL=\"jdbc:postgresql://${BBCMS_DB_HOST}:${BBCMS_DB_PORT}/${BBCMS_DB_NAME}\"; \
    fi; \
    if [ -z \"$BBCMS_FRONTEND_BASE_URL\" ] && [ -n \"$RENDER_EXTERNAL_URL\" ]; then \
      export BBCMS_FRONTEND_BASE_URL=\"$RENDER_EXTERNAL_URL\"; \
    fi; \
    exec java $JAVA_OPTS -jar app.jar \
"]
