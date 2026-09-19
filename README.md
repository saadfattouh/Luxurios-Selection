# Luxurious Selection — Phase 1

A tablet-first photography exhibition, with a Flutter collector app and a Laravel 13 API.

**Status: backend verified; Flutter implementation awaits execution approval and device verification. Phase 1 is not signed off.**

Start with [RUNBOOK](docs/RUNBOOK.md). Read [PROJECT_STATE](docs/PROJECT_STATE.md) and [Phase 1 handoff](docs/handoffs/PHASE_01.md) before continuing. The complete [CORE_EXPERIENCE](docs/CORE_EXPERIENCE.md) is binding.

- `apps/collector_app`: feature-first Flutter app, Android and web runners, tests.
- `services/api`: Laravel 13, Eloquent, PostgreSQL, resources, factories, seed media and tests.
- `docs/openapi.json`: OpenAPI 3.0.3 contract.
- `infra`: local PostgreSQL, setup and verification scripts.
- `tests`: cross-stack contract validation.

No reservations, payment, search, CMS, AR, or artwork-detail browsing is implemented.
