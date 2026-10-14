# Project state

Milestone: Phase 2 — Exhibition Discovery and Artwork Experience.

Status: source implementation and backend verification complete; Flutter/device acceptance pending. Phase 2 is not yet signed off end to end.

## Starting point

Continued `saadfattouh/Luxurios-Selection` main at `09465cdb612f14121971e35f437b308d75bd3b74`. The checkout was clean and contained the user's media/CORS changes, Android runner updates and Flutter lockfile. All eleven authoritative documents were read. No AGENTS.md was present. The original Phase 1 architecture and tests remain.

## Implemented

- Existing entrance and home lead into collection/exhibition browsing and a shared artwork focus view.
- Four collection atmospheres, lazy horizontal pages, bounded hero prefetch, shared-element approach/back, progressive story/biography/edition/price display, local shortlist behind a persistence interface.
- In-session gallery position and filters survive artwork navigation. Reduced-motion and loading/offline/empty/missing-image/API-error states are implemented.
- Five additional read-only routes complete the requested six-route set (exhibition detail already existed). Validated filters, UUID cursor pagination, lightweight stream resources, detailed artwork resource, publication filtering and ETags.
- Additive migration for rendition metadata, edition availability/pricing and query indexes. CLI rendition generation; demo seeder keeps existing IDs and includes fictional prices and a sold-out state.
- Backend feature/resource/validation/query/pagination checks; Flutter widget/navigation/state tests and live journey/profile instrumentation.
- Updated API/OpenAPI, model, architecture, design, motion, decisions, runbook and testing documentation. Exact continuation is in `handoffs/PHASE_02.md`.

## Verified

- Original Phase 1 backend: 10 tests / 74 assertions after fixing the workspace harness's test-database environment.
- Phase 2 including Phase 1: 20 tests / 204 assertions passed against PostgreSQL WASM via PDO pgsql.
- Laravel Pint and PHPStan passed during implementation. OpenAPI structure and legacy response validation passed.
- Dart source parsed/formatted with dart_style WASM; this is not Flutter analysis or a runtime test.
- Live Phase 2 HTTP smoke and four captured response contracts passed. See `TESTING.md` and `evidence/phase-02` for evidence.

## Pending / limitations

- Flutter analyzer, widget/integration tests, Android build, screenshots, accessibility and real tablet performance have not been verified in this workspace. The previous Flutter startup approval block was not bypassed.
- Native PostgreSQL CI remains separate from the PostgreSQL WASM evidence.
- No golden baselines were fabricated; there was no established golden suite or rendered Flutter output to approve.
- Position restoration is in-session Back navigation, not process-death/deep-link restoration.
- Six fictional works still reuse four source images; production photography/licensing and full Arabic UI/RTL remain outstanding.
- Shortlist is session-memory only. Rendition orphan cleanup, conditional JSON caching in Flutter and production deployment are deferred.
- Semantic search, wall configuration, reservations, payment, CMS and AR remain outside Phase 2.
