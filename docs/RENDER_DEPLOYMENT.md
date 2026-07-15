# Déploiement sur Render

Ce document explique comment le déploiement Render de BBCMS a été mis en place, en
remplacement de `docker-compose.yml` (qui reste dédié au dev local — inchangé, non
utilisé par Render).

## Pourquoi pas docker-compose.yml directement

Render n'exécute pas `docker-compose.yml`. Chaque service doit être déclaré comme une
ressource Render indépendante (base de données managée, service web, worker...), via un
fichier **`render.yaml`** à la racine du repo — un "Blueprint" qui joue le rôle
d'équivalent déclaratif au compose, mais où chaque service est provisionné et scalé
séparément plutôt que d'être des conteneurs reliés sur un même réseau Docker local.

## Mapping docker-compose → Render

| Service docker-compose | Ressource Render | Pourquoi |
|---|---|---|
| `postgres` (conteneur `postgres:16-alpine`) | Postgres managé Render (`databases:` dans `render.yaml`, nom `bbcms-db`) | Backups/failover inclus, pas de volume à gérer soi-même. |
| `minio` | Stockage S3-compatible externe (Cloudflare R2 / AWS S3 / Backblaze B2 — à choisir) | Render n'a pas d'équivalent S3 natif et son filesystem est éphémère par défaut (disque persistant = option payante par service). Le SDK MinIO déjà utilisé côté backend (`io.minio:minio`) est compatible avec ces fournisseurs sans changement de code : seuls l'endpoint et les clés changent. |
| `mailhog` | Retiré (dev-only) — vrai fournisseur SMTP | Mailhog capture les emails en local, inutile en prod. |
| `app` (build du `Dockerfile` local) | Web Service Render, `runtime: docker` (`services:` dans `render.yaml`, nom `bbcms-app`) | Réutilise le même `Dockerfile` multi-stage (Flutter web + Spring Boot jar) déjà utilisé pour le dev/prod local — aucune image séparée à maintenir. |

`docker-compose.yml` n'a pas été modifié : il continue de servir uniquement le dev local
(postgres + minio + mailhog + app). `render.yaml` est un chemin de déploiement additif et
indépendant.

## Fichiers concernés

- **`render.yaml`** (nouveau, racine) — le Blueprint décrit ci-dessus.
- **`Dockerfile`** (patché) — l'`ENTRYPOINT` du stage `runtime` :
  1. reconstruit `BBCMS_R2DBC_URL`/`BBCMS_JDBC_URL` à partir de `BBCMS_DB_HOST`/
     `BBCMS_DB_PORT`/`BBCMS_DB_NAME` si ces variables sont présentes (cas Render) ;
  2. si `BBCMS_FRONTEND_BASE_URL` n'est pas défini, le reprend depuis
     `RENDER_EXTERNAL_URL` (variable injectée automatiquement par Render dans tout
     service web — pas besoin de la déclarer dans `render.yaml`).

  En local (`docker-compose`), ni `BBCMS_DB_HOST` ni `RENDER_EXTERNAL_URL` ne sont
  définis, donc le comportement existant (valeurs fixées directement dans
  `docker-compose.yml`, ou défaut `application.yml`) reste inchangé.

### Pourquoi cette reconstruction est nécessaire

Render fournit les identifiants de connexion Postgres managé sous forme de propriétés
séparées (`host`, `port`, `database`, `user`, `password`) ou d'une `connectionString`
au format `postgres://user:pass@host:port/db`. L'application attend des URLs avec des
schémas différents — `jdbc:postgresql://...` et `r2dbc:postgresql://...` — sans
user:pass intégré dans l'URL pour le driver JDBC standard. Comme `render.yaml` ne
permet aucune transformation de chaîne, on câble les composants séparés via
`fromDatabase` et on reconstruit les deux URLs complètes dans l'entrypoint du conteneur
au démarrage.

## Variables d'environnement du service `bbcms-app`

| Variable | Origine | Action requise |
|---|---|---|
| `BBCMS_DB_HOST`, `BBCMS_DB_PORT`, `BBCMS_DB_NAME`, `BBCMS_DB_USER`, `BBCMS_DB_PASSWORD` | `fromDatabase` (base `bbcms-db`) | Aucune — câblage et mise à jour automatiques par Render. |
| `BBCMS_JWT_SECRET` | `generateValue: true` | Aucune — Render génère un secret aléatoire ≥ 256 bits au provisioning. |
| `BBCMS_SUPER_ADMIN_EMAIL`, `BBCMS_SUPER_ADMIN_PASSWORD` | `sync: false` | **Obligatoire.** Sans défaut côté code — si vides, `SuperAdminBootstrap` saute silencieusement la création du compte (juste un `log.warn`, pas d'erreur) : l'app démarre, healthcheck vert, mais personne ne peut se connecter. |
| `BBCMS_SUPER_ADMIN_FIRST_NAMES`, `BBCMS_SUPER_ADMIN_NEXT_NAMES` | `sync: false` | Optionnel — défauts codés en dur `"Super"`/`"Admin"` (`SuperAdminProperties.java`). Purement cosmétique si laissées vides. |
| `BBCMS_MINIO_ENDPOINT`, `BBCMS_MINIO_ACCESS_KEY`, `BBCMS_MINIO_SECRET_KEY`, `BBCMS_MINIO_BUCKET` | `sync: false` | Saisie manuelle avec les identifiants du fournisseur S3-compatible choisi. |
| `BBCMS_SMTP_HOST`, `BBCMS_SMTP_PORT` | `sync: false` | Saisie manuelle avec les identifiants du vrai fournisseur SMTP. |
| `BBCMS_FRONTEND_BASE_URL` | `sync: false`, mais auto-résolu par l'entrypoint | **Aucune par défaut.** Render injecte automatiquement `RENDER_EXTERNAL_URL` (URL publique complète, `https://...`) dans tout service web ; l'entrypoint du `Dockerfile` l'utilise si `BBCMS_FRONTEND_BASE_URL` est vide. Ne renseigner manuellement que pour forcer un domaine custom à la place de l'URL `onrender.com`. |
| `BBCMS_DEV_DATA_ENABLED` | `value: "false"` (fixe) | Aucune — désactive le seed de données de dev en production. |

## Gérer les variables `sync: false`

Une variable marquée `sync: false` dans `render.yaml` n'est **pas** définie par le
Blueprint — elle crée un emplacement vide que l'on remplit soi-même, une fois, côté
Render :

- **Saisie initiale** : au lancement du Blueprint (`New +` → `Blueprint` → sélectionner
  le repo), Render affiche un formulaire listant tous les `sync: false` à renseigner
  avant le premier déploiement.
- **Modification ultérieure** : Dashboard Render → service `bbcms-app` → onglet
  **Environment** → éditer/ajouter une variable → redeploy automatique, sans passer par
  Git.
- **Environment Groups** : pour partager des secrets entre plusieurs
  services/environnements (ex. staging + prod), regrouper les variables dans un groupe
  nommé réutilisable, modifiable à un seul endroit.
- **CLI/API** : `render env set ...` (Render CLI) ou l'API REST Render, pour scripter la
  gestion sans committer les valeurs.
- Les variables auto-câblées (`fromDatabase`, `generateValue: true`) n'ont rien à gérer
  manuellement — Render les tient à jour automatiquement (ex. si la base est recréée,
  `BBCMS_DB_HOST` se met à jour tout seul, sans intervention).

## Procédure de déploiement pas à pas

> ⚠️ Cette procédure suppose un déploiement **via le Blueprint `render.yaml`**
> (`New +` → `Blueprint`), qui est le seul chemin où `BBCMS_DB_HOST`/`PORT`/`NAME`/
> `USER`/`PASSWORD` sont câblées automatiquement et où `BBCMS_FRONTEND_BASE_URL` se
> résout toute seule. Un service créé à la main (`New +` → `Web Service`, en collant les
> variables une par une) **ne bénéficie d'aucun de ces deux automatismes** : il faut
> alors reconstruire les URLs DB soi-même et fournir une vraie URL publique — c'est une
> source d'erreurs fréquente (ex. `BBCMS_R2DBC_URL` laissée vide, `BBCMS_MINIO_ENDPOINT`
> laissée sur `http://localhost:9000` copié depuis `.env.local` — aucun des deux ne
> fonctionne sur Render). Si un service a déjà été créé ainsi, le plus simple est de le
> supprimer (Dashboard → service → Settings → tout en bas → **Delete Web Service**) et de
> repartir sur le Blueprint ci-dessous.

### 0. Prérequis à préparer AVANT de lancer le Blueprint

Le formulaire du Blueprint va te demander ces valeurs d'un coup — les avoir sous la main
évite les allers-retours :

- **Stockage S3-compatible** (remplace MinIO) : créer un compte + un bucket chez
  Cloudflare R2 (ou AWS S3 / Backblaze B2), puis générer une clé API. Tu obtiens :
  `endpoint` (ex. `https://<account-id>.r2.cloudflarestorage.com`), `access key`,
  `secret key`, `nom du bucket`.
- **SMTP réel** (remplace mailhog) : créer un compte chez un fournisseur SMTP
  (SendGrid/Mailgun/SES/…), noter `host` et `port` (ex. `smtp.sendgrid.net` / `587`).
  ⚠️ Voir la limitation "SMTP en production" ci-dessous : `auth`/TLS ne sont pas encore
  câblés côté code, donc l'envoi d'email échouera tant que ce n'est pas fait — non
  bloquant pour un premier déploiement de test, mais à traiter avant un vrai lancement.
- **Repo Git** : ce repo (avec `render.yaml`, `Dockerfile`, `.dockerignore`) poussé sur
  un remote GitHub/GitLab connecté à ton compte Render.

### 1. Lancer le Blueprint

Dashboard Render → **New +** → **Blueprint** → sélectionner ce repo. Render lit
`render.yaml` à la racine et affiche les ressources qu'il va créer : la base `bbcms-db`
(Postgres) et le service `bbcms-app` (Web Service, docker).

### 2. Remplir le formulaire des variables `sync: false`

Uniquement celles-ci (tout le reste — `BBCMS_DB_*`, `BBCMS_JWT_SECRET` — est déjà
auto-rempli, pas de champ à remplir pour elles) :

| Variable | Valeur à saisir |
|---|---|
| `BBCMS_SUPER_ADMIN_EMAIL` | ton email admin, ex. `admin@chf.org` |
| `BBCMS_SUPER_ADMIN_PASSWORD` | un mot de passe fort — **obligatoire**, sinon aucun compte admin n'est créé |
| `BBCMS_SUPER_ADMIN_FIRST_NAMES` / `NEXT_NAMES` | optionnel, laisser vide pour garder "Super Admin" |
| `BBCMS_MINIO_ENDPOINT` / `ACCESS_KEY` / `SECRET_KEY` / `BUCKET` | les 4 valeurs obtenues à l'étape 0 chez ton fournisseur S3 — **pas** `localhost:9000`/`minioadmin` |
| `BBCMS_SMTP_HOST` / `BBCMS_SMTP_PORT` | les valeurs de ton fournisseur SMTP — **pas** `localhost:1025` |
| `BBCMS_FRONTEND_BASE_URL` | **laisser vide** — auto-résolue via `RENDER_EXTERNAL_URL` |

### 3. Lancer le déploiement

Render provisionne d'abord `bbcms-db`, puis build et déploie `bbcms-app` à partir du
`Dockerfile` (Flutter web + Gradle `bootJar`) — potentiellement long au premier build
(voir limitations ci-dessous). Suivre l'onglet **Logs** du service jusqu'à l'état
**Live**.

### 4. Vérifier le câblage automatique

Dashboard → service `bbcms-app` → onglet **Environment** : `BBCMS_DB_HOST`,
`BBCMS_DB_PORT`, `BBCMS_DB_NAME`, `BBCMS_DB_USER`, `BBCMS_DB_PASSWORD` doivent apparaître
avec une icône de lien vers `bbcms-db` (valeurs non vides, non éditables directement —
c'est normal, elles suivent la base). Si l'une de ces 5 est absente ou vide, le Blueprint
n'a pas été utilisé correctement — reprendre à l'étape 1.

### 5. Tester

- `https://<url-du-service>.onrender.com/actuator/health` → doit répondre `UP`
  (healthcheck déjà `permitAll` dans `SecurityConfiguration`).
- Se connecter avec l'email/mot de passe saisis à l'étape 2 sur
  `POST /api/v1/bbcms/auth/login`.
- Si un domaine custom est ajouté plus tard (Dashboard → Settings → Custom Domains),
  renseigner alors `BBCMS_FRONTEND_BASE_URL` manuellement (Environment) pour le forcer à
  la place de l'URL `onrender.com` auto-détectée.

## Limitations connues / TODO

- **SMTP en production** : `application.yml` a `mail.smtp.auth: false` et
  `starttls.enable: false` codés en dur, adapté uniquement à Mailhog. Un vrai
  fournisseur SMTP nécessitera quasi systématiquement `auth: true` + STARTTLS +
  `spring.mail.username`/`password`. Non traité dans ce déploiement initial — à faire
  une fois le fournisseur SMTP choisi.
- **Temps de build Render** : le build Docker multi-stage (Flutter + Gradle) peut être
  lourd/long sur les plans de build standards de Render. À surveiller au premier
  déploiement ; envisager un plan de build supérieur en cas de timeout.
- **Syntaxe du Blueprint** : Render fait évoluer occasionnellement les clés de
  `render.yaml` (ex. l'ancien `env: docker` est devenu `runtime: docker`). Ce fichier a
  été écrit avec la syntaxe documentée au moment de sa création — à revalider contre la
  référence `render.yaml` de Render si le format a changé entre-temps.
- **Fallback SPA côté Flutter web** : un refresh sur une route profonde côté client
  (`go_router`) renverra un 404 côté Spring, faute de route de fallback vers
  `index.html` — limitation déjà connue du bundling frontend+backend, indépendante de
  Render.
