# Phase 1 handoff

## Acceptance status

**Not yet signed off.** Backend behavior is executable and verified in the workspace's PostgreSQL WebAssembly harness. Flutter source is implemented but has not been run, analyzed, built, or visually inspected. This is a transparent implementation handoff, not a claim that the running vertical slice is complete.

## Read first

1. ../CORE_EXPERIENCE.md — complete original product north star.
2. ../PROJECT_STATE.md and ../DECISIONS.md.
3. ../ARCHITECTURE.md, ../DATA_MODEL.md, ../API_CONTRACT.md and ../openapi.json.
4. ../DESIGN_SYSTEM.md, ../MOTION_SPEC.md, ../RUNBOOK.md and ../TESTING.md.

## What exists

`apps/collector_app/lib/features/exhibition` contains typed models, the API-backed repository, view model, image presentation, entrance and home. Provider is configured in main.dart. `/` is the entrance, `/exhibition` the home. The app requests `/api/v1/home/curation`; no fixture is used in production.

`services/api/app` contains models, Form Request, API Resources, GetCuration, storage interface/implementation, request logging middleware and Problem rendering. Migrations include domain tables and queue tables. DatabaseSeeder upserts fixed UUIDs and loads bundled photos. There is no CMS or write API.

`tests/workspace_postgres` preserves the optional verification harness; it uses actual PostgreSQL WASM through a wire adapter, separate ephemeral instances and PDO pgsql. Standard development/CI uses native PostgreSQL via infra/compose.yaml.

## Exact next steps: complete Phase 1 gate

1. Use an approved Flutter environment. Automatic approval review blocked this workspace's Flutter startup because it attempted a cloud instance metadata endpoint. Do not bypass that block.
2. Follow RUNBOOK.md. Resolve packages, commit pubspec.lock, and pin the SDK version that passes. Android runner templates were based on Flutter 3.47.4; they remain unbuilt.
3. Run Flutter analyzer and unit/widget tests; fix any issues revealed. Run native PostgreSQL tests via CI/Compose.
4. Launch API and Flutter together. Ensure APP_URL is reachable by the device as well as API_BASE_URL. Run the live integration test.
5. Verify 1280×800, 800×1280 and 390×844, normal and 1.6× text scale, reduced motion, retry/offline and missing images. Capture screenshots from the actual Flutter app.
6. Build a debug APK and web app. Profile entrance on the tablet; verify hero transition and TalkBack/touch behavior.
7. Update TESTING.md, PROJECT_STATE.md and this handoff with actual results. Only then mark Phase 1 complete.

## Phase 2 starting point after the gate

Add paginated artwork discovery and an artwork detail endpoint/resource, reusing stable IDs, storage URLs, publication filtering and error conventions. Extend the repository without moving network work into views. Build collection-responsive visual environments and the artwork approach interaction using existing tokens and Hero continuity. Preserve entrance/home/retry/reduced motion and regression tests.

Do not add semantic search, wall configuration, reservations, payment, CMS or production AR as part of finishing Phase 1. Future milestones should follow the existing phased prompts.
