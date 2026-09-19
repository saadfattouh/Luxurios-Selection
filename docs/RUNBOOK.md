# Runbook

## Prerequisites

- PHP 8.3+ with pdo_pgsql, mbstring, XML/DOM, fileinfo, ctype, curl, OpenSSL, tokenizer and GD.
- Composer 2, Docker with Compose v2 (or your own PostgreSQL 17 instance).
- Flutter stable with Dart ≥3.8, Android SDK and Java 17 for Android; Chrome for a web preview.
- Internet access for the initial Composer, Flutter and Gradle downloads.

This source was created in a tool-constrained environment. PHP setup and API behavior were verified; the full Flutter build and native PostgreSQL setup below are pending external execution. See TESTING.md before treating this as signed off.

## Setup (macOS/Linux/WSL)

From the repository root:

```bash
bash infra/setup.sh
```

The script starts PostgreSQL, creates the local `.env` if absent, installs locked PHP dependencies, generates the app key if absent, migrates and seeds, links public media, and resolves Flutter packages. It never invokes migrate:fresh. The bundled database password is a development-only default for loopback PostgreSQL. Use private environment values elsewhere.

For Windows without WSL, run the same commands individually in PowerShell (create the listed storage folders first):

```powershell
docker compose -f infra/compose.yaml up -d --wait
cd services/api
Copy-Item .env.example .env  # only when .env does not exist
composer install
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
cd ../../apps/collector_app
flutter pub get
```

The Android runner is included. Flutter creates local.properties from your SDK configuration. Gradle wrapper uses Gradle 9.3.1 / AGP 9.1.0 / Kotlin 2.4.0, taken from the retrieved stable Flutter templates; compatibility must still pass the pending build gate. Do not commit SDK paths. Release signing is not configured for production.

## Run API and app

Terminal 1:

```bash
cd services/api
php artisan serve --host=0.0.0.0 --port=8000
```

Terminal 2, browser:

```bash
cd apps/collector_app
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:8000/api/v1/
```

Android emulator:

```bash
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1/
```

**Media URLs matter:** for the Android emulator set API `.env` APP_URL to `http://10.0.2.2:8000`, then `php artisan config:clear`. The API base URL controls requests; APP_URL controls serialized media URLs. For a physical tablet use your computer's reachable LAN IP for BOTH values. Restart after changes. HTTP is allowed only in the Android debug manifest. Production needs HTTPS.

Default CORS allows localhost/127.0.0.1 port 8080. If the web preview origin changes, update CORS_ALLOWED_ORIGINS and clear config. Android native requests do not use browser CORS.

## Demonstrate

1. Run `curl http://localhost:8000/api/v1/health` and `/api/v1/ready`.
2. Open app; identity loads, then “Beyond the horizon” and the mountain image emerge.
3. Tap Enter Exhibition. The same image anchors the home above the five editorial sections.
4. Tablet artwork sequences scroll horizontally; phones stack works vertically.
5. Stop API and relaunch app: retry is visible, with no silent fixture substitution.
6. Enable reduced motion / large system text; repeat at landscape, portrait and phone sizes.

Fictional work/photographer details and reference imagery are for demonstration only. They imply no ownership, sales rights or real artist relationship.

## Verify

```bash
bash infra/verify.sh
cd apps/collector_app
flutter test integration_test/api_journey_test.dart -d <android-device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1/
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1/
```

PHPUnit forces DB_DATABASE=luxurious_test, and the test base class rejects any resolved database name without `_test` BEFORE database refresh. The Compose init script creates the test DB on first volume initialization. If an existing volume predates it, create `luxurious_test` manually; do not delete data to fix this.

`python3 tests/validate_contract.py` validates the saved real API response against the contract (requires jsonschema and openapi-spec-validator). Run `composer validate --strict` separately after dependency changes.

## Seed and operate

```bash
cd services/api
php artisan db:seed
php artisan queue:work --tries=3 --timeout=90
```

Seeding only works in local/testing. It upserts known UUIDs and copies bundled sample photos. Queue tables are ready; this phase dispatches no slow jobs. Health is liveness; readiness checks DB connectivity. `/api/v1/home/curation` is the content smoke check.

For S3-compatible production, set FILESYSTEM_DISK=s3 plus AWS credentials/bucket/region/endpoint, path-style setting and AWS_URL for the public CDN. Never seed production with sample data. Upload assets through controlled CLI/jobs in future work; no public upload route exists.

## Current environment blocker

Automatic approval review rejected Flutter startup because it attempted a cloud instance metadata endpoint, which may expose credentials. No bypass was used. Continue Flutter execution only in an approved development environment or after explicit approval of the blocked action. Backend evidence does not prove that Flutter rendering/builds pass.
