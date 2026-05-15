# BBCMS — Frontend Flutter

Application Flutter de gestion des Bible Clubs (BBCMS · CHF), connectée
au backend Spring Boot/WebFlux décrit à la racine du dépôt.

## Stack

| Couche             | Choix                       |
|--------------------|-----------------------------|
| Framework          | Flutter 3.24 (stable)       |
| Plateformes        | Android · iOS · Web         |
| State management   | flutter_bloc 8.x            |
| Routing            | go_router 14.x              |
| HTTP               | dio 5.x + interceptors      |
| Stockage tokens    | flutter_secure_storage / shared_preferences (web) |
| DI                 | get_it 8.x                  |
| Charts             | fl_chart 0.69               |
| Fonts (web load)   | google_fonts (Inter / Cormorant Garamond / JetBrains Mono) |

## Structure

```
lib/
├── main.dart, app.dart
├── core/
│   ├── api/           # Dio client, ApiConfig, FileUploader (multipart)
│   ├── auth/          # AuthBloc, AuthRepository, TokenStorage, CurrentUser (JWT)
│   ├── theme/         # AppColors, AppTypography, AppTheme, AppRadius/Spacing
│   ├── widgets/       # Tag, Avatar, RoundIconButton, BarProgress, Donut, Sparkline,
│   │                  # KpiCard, ScreenHeader, ChipX, SectionHeader
│   ├── router/        # GoRouter + auth guard
│   ├── di/            # service_locator.dart (get_it)
│   └── errors/        # ApiException
└── features/
    ├── auth/          # LoginPage, ForgotPasswordPage, ResetPasswordPage,
    │                  # ActivationPage, ChangePasswordPage
    ├── onboarding/    # OnboardingPage (wizard 4 étapes), OnboardingCubit,
    │                  # PublicRegistryRepository
    └── shell/         # WidgetGalleryPage (page de démo)
```

## Lancement

### Backend prérequis

Avant de lancer le frontend, le backend doit tourner. À la racine du dépôt :

```bash
docker-compose up -d           # Postgres + MinIO + MailHog
cp .env.example .env           # ajuster mots de passe si besoin
./gradlew bootRun              # http://localhost:8080
```

Au premier démarrage, le `DevDataSeeder` crée :
- 3 Bible Clubs (UNIKIN, UPC, ULUB) avec leurs niveaux L1..L4
- ~20 utilisateurs/membres (étudiants, leaders BBC, professionnels, mentor)
- ~12 réunions (mix RECORDED / PLANNED) sur les 8 dernières semaines
- 1 verset du jour, 2 annonces, 1 chaîne de prière active, 1 programme
  d'évangélisation, 1 contribution financière, 1 événement national

**Comptes de démo** (mot de passe par défaut `Demo_2025!`) :
- Étudiant : `marie.lukombo@chf.org`
- Leader BBC : `president.unikin@chf.org`
- Mentor : `mentor.mwamba@chf.org`
- Super-admin : `admin@chf.org` / `ChangeMeNow_2025!`

### Frontend Flutter

```bash
cd mobile
flutter pub get

# Web (recommandé pour test rapide)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080

# Android emulator
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS simulator
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8080
```

## URL backend configurable

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8080
```

Le préfixe `/api/v1/bbcms` est ajouté automatiquement.

## Tests & analyse

```bash
flutter analyze
flutter test
```

## État d'avancement (par phases)

| # | Phase                                  | Statut |
|---|----------------------------------------|--------|
| 0 | Foundation (theme, atomes, auth, DI)   | ✅ DONE |
| 1 | Auth + Onboarding (4 étapes + photo, forgot/reset/change/activation) | ✅ DONE |
| 2 | Shell de navigation (TabBar 5 onglets + drawer leader + stubs features) | ✅ DONE |
| 3 | Dashboards (membre / leader / national)| ⏳     |
| 4 | Réunions                               | ⏳     |
| 5 | Membres + Demandes d'adhésion          | ⏳     |
| 6 | Vie spirituelle                        | ⏳     |
| 7 | Finance                                | ⏳     |
| 8 | Évangélisation + Discipulat            | ⏳     |
| 9 | Événements nationaux                   | ⏳     |
| 10| Profil & Paramètres                    | ⏳     |
| 11| Admin (CRUD BBC, Reset annuel)         | ⏳     |
| 12| Polish & i18n                          | ⏳     |
