# BBCMS — Backend

Backend Java 21 / Spring Boot 3 / WebFlux pour le **Bible Club Management System** (CHF).
Architecture **hexagonale** stricte (ports & adapters), monolithe modulaire packagé en un seul JAR.

## Stack

| Couche | Choix |
|---|---|
| Langage | Java 21 LTS |
| Build | Gradle 8.14 (Kotlin DSL) |
| Framework | Spring Boot 3.3 (WebFlux réactif) |
| Persistance | R2DBC (PostgreSQL) + Liquibase |
| Auth | JWT HS256 (jjwt) + BCrypt + RBAC interne scopé par BBC |
| Scheduler | `@Scheduled` + ShedLock (lock distribué via DB) |
| Bus events | Outbox transactionnelle (`bbcms_domain_event`) + `ApplicationEventPublisher` |
| Médias | MinIO (S3-compatible) |
| Notifications | SMTP (V1), FCM/APNS/SMS (V2) |
| Observabilité | Micrometer / Prometheus / Actuator |
| Tests | JUnit 5, Reactor Test, ArchUnit, Testcontainers |

## Structure (package-by-feature, hexagonale)

```
com.chf.bbcms/
├── shared/         # BaseEntity, DomainEvent, Outbox, ApiErrorResponse
├── config/         # SecurityConfiguration, ShedLockConfig, MinioConfig
├── authentication/ # JWT, login, refresh, password reset, activation
├── authorization/  # Role, Permission, RBAC (scopé bibleClubId)
├── identity/       # UserAccount + MembershipRequest (PII = source de vérité ici)
└── (V2) organization, people, meeting, event, attendance, evangelism,
      discipleship, intercession, finance, publication, reset
```

Chaque module suit la structure hexagonale:
```
<module>/
├── domain/         # Agrégats, VOs, enums (zéro dépendance Spring)
├── application/
│   ├── port/in/    # Use cases interfaces
│   ├── port/out/   # Repositories interfaces, ports techniques
│   └── service/    # Implémentations
└── adapter/
    ├── in/web/         # REST controllers
    ├── in/security/    # JWT filter
    └── out/persistence/ # R2DBC repositories
```

## Démarrage

### Pré-requis
- Java 21
- Docker & docker-compose

### Lancement infra locale
```bash
docker-compose up -d
```

### Configurer le super-admin (auto-créé au démarrage)

Au premier démarrage, un compte super-admin avec le rôle `SYSTEM_ADMIN` (toutes les
permissions) est créé automatiquement à partir des credentials chargés depuis le
fichier `.env` à la racine de `bbcms/backend/`.

```bash
cp .env.example .env
# Éditer .env: BBCMS_SUPER_ADMIN_EMAIL et BBCMS_SUPER_ADMIN_PASSWORD
```

Le bootstrap est **idempotent**: re-démarrer ne crée pas de doublon, et ne
réécrase pas le mot de passe d'un compte existant. Pour désactiver:
`BBCMS_SUPER_ADMIN_ENABLED=false`.

> Le fichier `.env` est gitignoré. `.env.example` est versionné comme template.

### Lancement application
```bash
./gradlew bootRun
```

L'application démarre sur `http://localhost:8080`. OpenAPI: `http://localhost:8080/swagger-ui.html`.

Au démarrage, tu verras dans les logs:
```
✅ Super-admin created: admin@chf.org (id=...)
```
ou, si déjà créé:
```
Super-admin 'admin@chf.org' already exists (status=ACTIVE); skipping creation
```

### Tester rapidement

```bash
curl -X POST http://localhost:8080/api/v1/bbcms/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$BBCMS_SUPER_ADMIN_EMAIL\",\"password\":\"$BBCMS_SUPER_ADMIN_PASSWORD\"}"
```

### Tests
```bash
./gradlew test                              # tout
./gradlew test --tests "*ArchitectureTest"  # ArchUnit seulement
./gradlew test --tests "*IntegrationTest"   # Testcontainers
```

## Décisions techniques validées

- **PII**: source unique de vérité dans `bbcms_user_account` (pas de duplication dans `bbcms_member`)
- **Devise V1**: XAF unique
- **Évangélisation + events** comptent dans le score de fidélité
- **Sync offline**: V2 (pas dans cette V1)
- **RGPD**: anonymisation différée 24 mois après `REMOVED` (configurable via `bbcms_setting`)

## Migrations Liquibase

Master: `src/main/resources/db/changelog/db.changelog-master.xml`

Livré (Phase 1 + 2):
- `00-extensions` — pgcrypto
- `01-rbac-audit-settings` — Role, Permission, UserRoleAssignment, Setting
- `02-identity` — UserAccount, MembershipRequest, ActivationToken, PasswordResetToken, RefreshToken
- `03-organization` — BibleClub, Level (UNIQUE bbc+type), LeadershipAssignment
- `04-people` — Member (single-table polymorphisme, sans PII), MemberDepartment,
  MentorAssignment, Visitor (FK polymorphe corrigée: meeting_id XOR event_id)
- `14-domain-event-outbox` — table outbox transactionnelle
- `15-shedlock` — verrou distribué scheduler
- `16-seed-permissions` — catalogue (~70 permissions)
- `17-seed-roles` — 13 rôles standards + mappings
- `18-seed-settings` — seuils par défaut

## Endpoints livrés

| Méthode | Path | Permission |
|---|---|---|
| POST | `/api/v1/bbcms/auth/login` | (publique) |
| POST | `/api/v1/bbcms/auth/refresh` | (publique) |
| POST | `/api/v1/bbcms/auth/logout` | (publique) |
| POST | `/api/v1/bbcms/users` | (publique — VISITOR) |
| POST | `/api/v1/bbcms/users/activate?token=...` | (publique) |
| GET | `/api/v1/bbcms/users/{id}` | authentifié |
| GET | `/api/v1/bbcms/membership-requests?status=PENDING` | `bbcms:membership-request:read` |
| POST | `/api/v1/bbcms/membership-requests/{id}/approve` | `bbcms:membership-request:approve` |
| POST | `/api/v1/bbcms/membership-requests/{id}/reject` | `bbcms:membership-request:reject` |
| POST/GET/PUT/DELETE | `/api/v1/bbcms/bible-clubs[/{id}/...]` | `bbcms:bible-club:*` |
| POST/GET/PUT/DELETE | `/api/v1/bbcms/bible-clubs/{bbcId}/levels[/{id}/...]` | `bbcms:level:*` |
| GET/PUT/POST/DELETE | `/api/v1/bbcms/members[/{id}/...]` | `bbcms:member:*` |

À l'approbation d'une `MembershipRequest`, le `MembershipService` orchestre dans
une seule transaction R2DBC: promotion du `UserAccount.userType` + création du
`Member` correspondant (STUDENT/PROFESSIONAL/MENTOR/NATIONAL_LEADER).

Le JWT inclut désormais `bibleClubId` (extrait de `Member` du STUDENT) pour le
scope RBAC (RM-09).

## Reset annuel (Phase 5)

`POST /api/v1/bbcms/bible-clubs/{id}/reset` — workflow saga transactionnel:
1. BBC verrouillé en `UNDER_RESET` (RM-07: gel des écritures)
2. Snapshot annuel calculé (membres actifs, fidèles, % objectif)
3. Archive textuelle uploadée dans MinIO (PDF en V2)
4. Transferts L1→L2..L6→L7, L7→TRANSFERRED
5. `AttendanceScore` reset à 0 pour la nouvelle année académique
6. BBC repasse `ACTIVE`
7. Événement `BBC_RESET` publié sur l'outbox

## Dashboards

- `GET /api/v1/bbcms/dashboards/bible-clubs/{id}?academicYear=` — pilotage BBC
- `GET /api/v1/bbcms/dashboards/national?academicYear=` — vue nationale CHF

Permissions: `bbcms:dashboard:bbc` et `bbcms:dashboard:national`.

## Hardening

- **Rate limiting**: 10 req/min/IP sur `/auth/*` et `/users` (in-memory Caffeine)
  → HTTP 429 avec corps `BBCMS_RATE_LIMITED`
- **OpenAPI**: documentation auto-générée à `/swagger-ui.html`, schéma JWT Bearer
- **ArchUnit**: 7 garde-fous (domain pur, layered, conventions controllers/services)

## Sync offline (Phase 6)

Endpoint pull-only pour clients offline (push-back en V3, le client rejoue ses POST/PUT
quand il revient online):

```
GET /api/v1/bbcms/sync/changes
  Header: X-Device-Id: <id-stable-device>
  Query:  kind=MEETING|MEMBER|BIBLE_CLUB|... (cf SyncEntityKind)
          since=<ISO instant, optionnel>
          limit=100 (max 500)
```

Le serveur:
1. lit le curseur `(user, device, kind)` depuis `bbcms_sync_cursor`,
2. interroge la table cible où `updated_at > since` (ou `last_computed_at` pour scores),
3. avance le curseur jusqu'au plus récent `updated_at` du batch,
4. renvoie un `SyncBatch` avec changements + `cursorAdvancedTo`.

Réponse type:
```json
{
  "kind": "MEETING",
  "since": "2025-10-01T00:00:00Z",
  "cursorAdvancedTo": "2025-10-15T08:42:11.123Z",
  "count": 42,
  "changes": [{ "id": "...", "updatedAt": "...", "version": 3, "payload": { ... } }]
}
```

## PDF natif (Phase 6)

Les snapshots de reset annuel sont désormais générés en PDF natif via OpenPDF
(LGPL fork iText 2.x). Implémenté par `SnapshotPdfGenerator` derrière le port
`SnapshotRendererPort`. L'archive est uploadée dans MinIO (`application/pdf`).

## Notes

- Devices push: table `bbcms_device_token` créée (V2/V3 — l'adapter FCM stub reste OFF par défaut)
- Sync write-back: V3 (le client rejoue ses commandes online en attendant)
