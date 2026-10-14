# Phase 2 baseline — 2026-09-19

Source: saadfattouh/Luxurios-Selection main, 09465cdb612f14121971e35f437b308d75bd3b74. Clean checkout; no AGENTS.md. All eleven required context documents match the Phase 1 checkout already read.

Before editing: `bash infra/verify.sh` exited 127 (vendor/bin/pint missing). PHP and Flutter were not on PATH. HTTP GET 127.0.0.1:8000/api/v1/health failed to connect. These are environment/dependency blockers, not passing tests or application failures. Android SDK/device unavailable. Historical Phase 1 results remain separately in docs/evidence.

Changes inherited from GitHub include pubspec.lock, Android runner updates, and a CORS media route. Source inspection found duplicate allowed_origins_patterns in CORS configuration; the media route is not used by MediaUrlResolver and hard-codes one origin. These are pre-existing source issues to fix while retaining the route and public disk abstraction.

Flutter startup was previously rejected by automatic review for a metadata endpoint request. This turn does not retry that blocked startup. Device builds and profiling remain unverified.

Follow-up baseline execution: extracted PHP runtime enabled all original tests. Initial harness test DB setting was rejected by the existing isolation guard; explicit DB_DATABASE=luxurious_test and APP_ENV=testing corrected the harness. Untouched application code then passed 10 tests / 74 assertions. Baseline live HTTP smoke passed. Original Pint reported formatting issues in routes/api.php and config/cors.php.
