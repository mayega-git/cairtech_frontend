#!/bin/bash

# Récupérer le chemin absolu du dossier racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# S'assurer que le script s'arrête proprement en tuant les processus en arrière-plan
cleanup() {
  echo ""
  echo "⏹️  Arrêt des processus..."
  if [ -n "$BACKEND_PID" ]; then
    kill "$BACKEND_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "🐳 1. Démarrage de l'infrastructure Docker (Postgres, MinIO, MailHog)..."
cd "$PROJECT_ROOT"
docker-compose up -d

# Initialiser le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
  echo "📝 Création du fichier .env à partir de .env.example..."
  cp .env.example .env
fi

echo "🚀 2. Démarrage du Backend Spring Boot (en arrière-plan)..."
./gradlew bootRun > backend.log 2>&1 &
BACKEND_PID=$!

echo "⏳ Attente du démarrage complet du backend sur http://localhost:8080..."
# Attendre que le port 8080 réponde
while ! curl -s http://localhost:8080 > /dev/null; do
  sleep 2
done

echo "✅ Le Backend est prêt !"

echo "📱 3. Démarrage du Frontend Flutter..."
cd "$PROJECT_ROOT/mobile"
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
