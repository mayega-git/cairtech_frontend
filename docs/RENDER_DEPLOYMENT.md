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
| `BBCMS_SUPER_ADMIN_EMAIL`, `BBCMS_SUPER_ADMIN_PASSWORD`, `BBCMS_SUPER_ADMIN_FIRST_NAMES`, `BBCMS_SUPER_ADMIN_NEXT_NAMES` | `sync: false` | Saisie manuelle (voir procédure ci-dessous). |
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

## Étapes de déploiement

1. Pousser ce repo (avec `render.yaml` et le `Dockerfile` patché) sur un remote Git
   (GitHub/GitLab) connecté à Render.
2. Dans le Dashboard Render : `New +` → `Blueprint` → sélectionner le repo → Render lit
   `render.yaml` et propose de créer `bbcms-db` (Postgres) et `bbcms-app` (Web Service).
3. Remplir le formulaire des variables `sync: false` (admin email/password, clés S3,
   creds SMTP). Laisser `BBCMS_FRONTEND_BASE_URL` vide — elle se résout automatiquement
   au démarrage via `RENDER_EXTERNAL_URL` (voir tableau ci-dessus) ; ne la renseigner que
   si un domaine custom est prévu.
4. Lancer le déploiement. Le build exécute le `Dockerfile` (Flutter web + Gradle
   bootJar) — potentiellement long (voir limitations ci-dessous).
5. Une fois déployé, l'URL publique assignée par Render (ex.
   `https://bbcms-app.onrender.com`, visible en haut du Dashboard du service) est déjà
   utilisée automatiquement comme `BBCMS_FRONTEND_BASE_URL`. Si un domaine custom est
   configuré ensuite (Dashboard → Settings → Custom Domains), renseigner alors
   `BBCMS_FRONTEND_BASE_URL` manuellement via Dashboard → Environment pour le forcer à
   la place de l'URL `onrender.com`.
6. Vérifier `https://<url-render>/actuator/health` (healthcheck configuré dans
   `render.yaml`) puis tester le login super-admin avec les creds saisies à l'étape 3.

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
