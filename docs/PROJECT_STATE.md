# Project state

Milestone: Phase 1 — Foundation, Architecture and Exhibition Entrance.

**Status: source implementation delivered; backend verified; end-to-end acceptance blocked. Do not start Phase 2 implementation yet.**

## Implemented

- Complete original north-star brief saved as CORE_EXPERIENCE.md.
- New monorepo and baseline Git checkpoint (8f75c18).
- Laravel 13 / PHP 8.3 app, PostgreSQL migrations and nine domain entities with factories.
- Repeatable sample seeder, bundled media, EN/AR content and publication controls.
- Six read-only v1 routes, resources, bounded curation, paginated indexes, validation, Problem Details, JSON logs, request IDs, throttling, health/readiness.
- Local/S3 filesystem URL abstraction and database queue foundation.
- Flutter MVVM-style source with Provider, typed API/repository layer, tokens, bootstrap and Android/web runners.
- Cinematic entrance, shared-image transition, responsive home sections, retry/loading/empty/image failure states, reduced-motion handling.
- Backend tests, Flutter unit/widget tests, a live integration test, contract validator and native PostgreSQL/Flutter CI configuration.
- Setup, verification, full API contract, design/motion documentation and handoff.

## Verified vs pending

See TESTING.md and evidence/verification.json. Backend migrations, seeder, tests and actual HTTP responses executed against PostgreSQL WebAssembly through PDO. PHP formatting/static analysis and OpenAPI validation passed. Dart formatting passed.

Flutter startup was rejected by automatic approval review for a cloud metadata request. Flutter package resolution, analyzer, tests, app builds, screenshots and physical-device verification are NOT complete. Native PostgreSQL CI is also pending. There is no deployed site and no confirmed end-to-end Flutter/API demonstration.

## Decisions to preserve

Use Flutter and Laravel; do not replace with a web mockup. Keep photographs as the visual heroes, the API as normal data source, and the brief as the binding experience. Do not implement Phase 2 browsing/details/search prematurely. A second environment should finish the verification gate first.

## Known limitations

- Full Arabic UI/RTL is future work; EN/AR data fields exist now.
- Four source-image variants are reused across six fictional works; originals and commercial licensing are not provided.
- System typography is provisional. No device profiling or visual approval has happened.
- Room/frame/size foundations have no configuration interface yet.
- Flutter dependency lock and verified SDK pin still need to be created after successful resolution.
- Production deployment/auth/admin/payment are out of scope.
