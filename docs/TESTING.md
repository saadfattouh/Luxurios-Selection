# Testing and verification

## Phase 1 historical results

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


## Phase 2 results and remaining gates

Evidence: `evidence/phase-02`. Original baseline checkout tests: 10 / 74 assertions. Extended suite: **20 / 204 assertions passed**, preserving the original tests. PostgreSQL SQL was executed through the PGlite wire harness and PDO pgsql, not SQLite. This does not claim native PostgreSQL CI passed.

The initial attempt was blocked by missing tools/dependencies. PHP 8.3.6 and required extensions were then extracted into a temporary directory. The inherited harness supplied DB_DATABASE=luxurious even to PHPUnit; the database guard correctly rejected it. Setting the test child explicitly to luxurious_test fixed the harness without weakening TestCase's guard. Original Pint issues were confined to the media route and CORS configuration; these files were refined as part of Phase 2.

Laravel Pint and PHPStan passed. OpenAPI 3.0.3 structure and the recorded legacy curation payload validate. Dart files were parsed/formatted with the dart_style WASM package; that does not replace Flutter analyzer or widget execution.

New backend coverage: lightweight serialization, UUID/slug details, safe publication/404 behavior, combined filters on the same edition, malformed query/cursor validation, cursor insertion stability, bounded query count, ETag 304 and edition invalidation, real rendition/CORS reads, and unknown availability/price preservation.

New authored Flutter coverage: four atmospheres at tablet/phone with enlarged text; API query encoding; late-response suppression; retry; local shortlist; approach/reveal/Back page restoration with and without reduced motion; missing-image/partial detail; live seeded journey and profile instrumentation. These tests have **not run** here. No golden baselines or screenshots are supplied, because no actual Flutter render was produced. Existing Phase 1 widget tests remain.

Performance: longest-edge rendition caps 480/1280/1920, lazy PageView construction, only next hero prefetch, fullscreen fetched only on focus, and 64 MiB / 40-entry image cache are implemented controls. They are not device measurements. Full image-memory usage, first meaningful display, scroll/frame stability, transition smoothness and TalkBack require the Android profile run in RUNBOOK. No APK/web build was run in this task.

Live Phase 2 HTTP smoke passed on resumption: identities, paged stream with distinct next page, detail, photographer, conditional 304, three actual image rendition reads with CORS, invalid filter 422 and missing artwork 404. Four captured Phase 2 response contracts also validate. The representative landscape returned 480×320 thumbnail (44,148 bytes) and 1600×1067 fullscreen (438,521 bytes; no upscaling). These are asset measurements, not tablet memory/latency figures.

CI keeps the existing test suites and one Android build gate. Feature branches run on pull requests; main still runs on push, avoiding duplicate branch push/PR builds. The redundant web build was removed from CI; no new local build was run.
