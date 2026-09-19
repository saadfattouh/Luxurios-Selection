# Testing and verification

Evidence is recorded in evidence/verification.json, evidence/http-smoke.json and evidence/curation.json. No unrun Flutter test is reported as passing.

| Check | Result | Scope |
|---|---|---|
| PHP syntax | Passed, 40 files | Application, domain, seeders and tests |
| Laravel Pint | Passed | Entire API project |
| PHPStan | Passed, level 0 | App and database; baseline static analysis, not full generic Eloquent inference |
| Composer validate --strict | Passed | Manifest and lock validity |
| PHPUnit | Passed: 10 tests, 74 assertions | PDO pgsql against isolated PostgreSQL WASM instances |
| Real HTTP smoke | Passed | Six v1 endpoints, local hero JPEG, validation 422 and missing route 404 |
| Migrations / deterministic seed | Passed | Real PostgreSQL SQL engine; repeatable seeding tested |
| OpenAPI and response validation | Passed | OpenAPI 3.0.3 plus captured curation payload |
| Dart formatting | Passed, 12 files unchanged | Parsing/formatting only; package lint resolution warning |
| Android XML / shell / JS harness syntax | Passed | Static syntax checks only |
| Native PostgreSQL tests | Pending | GitHub Actions PostgreSQL 17 service authored |
| Flutter analyzer | Blocked / not run | Startup approval rejection |
| Flutter unit/widget tests | Authored / not run | API decoding/errors, view model retry/disposal, responsive layouts |
| Flutter live integration | Authored / not run | Requires API, seeded DB and device |
| Android/web development builds | Not run | Flutter blocked; Android SDK absent |
| Screenshots, motion/performance, accessibility | Not verified | Requires a running app/device |

## Why runtime coverage is limited

The initial workspace had no PHP, Composer, Flutter, Dart, PostgreSQL, Docker or Android SDK. PHP 8.3.30, Composer dependencies and Flutter source were downloaded. Native PostgreSQL cannot run under this root-only mapped UID. An isolated PGlite/PostgreSQL WebAssembly wire server enabled actual migrations, database-backed HTTP requests and PHPUnit integration tests without changing the application's PostgreSQL driver or using SQLite.

Automatic approval review rejected Flutter startup for attempting a cloud instance metadata endpoint, which could expose credentials. No workaround was used to execute Flutter after this rejection. Local Dart formatting is a separate, offline source check; it is not a Flutter build/analyzer/test result. No preview from another technology has been substituted.

PHPStan's optional turbo extension cannot load in the static PHP binary; standard analysis completed successfully. The native PostgreSQL and Flutter CI workflow has been authored, not run remotely.

## Test isolation and regression requirements

PHPUnit forces APP_ENV=testing and DB_DATABASE=luxurious_test. TestCase checks the resolved connection and database name before RefreshDatabase. Every feature test uses transaction isolation. Tests cover repeatable seed counts, curation serialization, index validation/pagination, draft/future exclusion, private hero suppression, read-only methods, health/readiness, media URLs, safe readiness failures, and edition constraints. The storage resolver unit test verifies the selected disk/path abstraction.

Flutter fixture JSON is an exact real API snapshot. Layout tests target 1280×800, 800×1280 and 390×844 with large text and reduced motion. They use a fake repository; the separate integration test uses the actual configured API. No fixture fallback exists in production.

Before Phase 2, all pending gates above must pass and actual Flutter screenshots should be committed or attached with device/viewport details. Run commands are in RUNBOOK.md; infra/verify.sh is the normal consolidated check.
