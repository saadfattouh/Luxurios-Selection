#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose -f infra/compose.yaml up -d --wait
cd services/api
[ -f .env ] || cp .env.example .env
mkdir -p bootstrap/cache storage/app/public storage/framework/{cache/data,sessions,views} storage/logs
composer install
if ! grep -q '^APP_KEY=base64:' .env; then php artisan key:generate; fi
php artisan migrate --seed
[ -L public/storage ] || php artisan storage:link
cd ../../apps/collector_app
flutter pub get
