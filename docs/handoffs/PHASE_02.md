# Phase 2 handoff

## Status and continuity

Implementation is ready for Flutter/device acceptance; not an end-to-end sign-off. Continue this repository rather than rebuilding it. Source baseline was main commit `09465cdb612f14121971e35f437b308d75bd3b74`. Phase 1 tests and entrance/home remain intact. The work resumed on 2026-10-14 after its September implementation/checks; historical evidence dates are retained.

Read CORE_EXPERIENCE, PROJECT_STATE, ARCHITECTURE, API_CONTRACT/openapi.json, DATA_MODEL, DESIGN_SYSTEM, MOTION_SPEC, DECISIONS, RUNBOOK and TESTING before continuing.

## User journey implemented

Entrance → home → collection or exhibition → horizontal photograph discovery → approach → large photograph → reveal story/photographer/edition/indicative price and size → shortlist → step away to the same gallery position. All normal content uses APIs. Home works also open the same focus view. The four environments retain one navigation model.

## Code entry points

- `apps/collector_app/lib/features/discovery/data`: DiscoveryRepository / ApiDiscoveryRepository and ShortlistRepository / MemoryShortlistRepository.
- `.../presentation`: DiscoveryViewModel owns paging/filter state, DiscoveryView owns retained PageController, ArtworkFocusView owns progressive information, discovery_navigation owns route/Hero behavior, atmosphere owns collection tokens.
- Existing exhibition DTOs and ArtworkImage accept additive detail/rendition fields; the Phase 1 curation repository remains compatible.
- `services/api/app/Actions/GetArtworkStream.php`: validated UUID-keyset streams, publication predicates and bounded eager loads.
- `DiscoveryController`, `ArtworkStreamRequest`, `ArtworkSummaryResource`, extended detail resources and `PublicContentCache` define public discovery behavior.
- `BuildMediaRenditions` and `media:renditions`: explicit CLI display processing, no expensive HTTP operation.
- `2026_09_19_000001_add_discovery_metadata.php`: additive/reversible migration. Existing edition rows remain unknown/unpriced until populated.

## Demonstration setup

Follow RUNBOOK's Phase 2 upgrade commands. Use `migrate`, never `migrate:fresh` on the user's DB. Seed only for the known fictional demo IDs or run `media:renditions` for existing public media. Match APP_URL and API_BASE_URL to emulator/LAN reachability. There is no queue dependency in this phase.

## Evidence and unresolved acceptance

Backend suite: 20 tests, 204 assertions passed, including Phase 1. Native PostgreSQL CI is not interchangeable with this workspace's PGlite/PDO evidence. PHP formatting/static analysis, live Phase 2 HTTP smoke, OpenAPI validation and four captured response contracts passed. Baseline pre-existing formatter issues and harness database setting are recorded under evidence/phase-02.

Flutter tests are authored but unrun here. No device performance, accessibility, golden screenshots or build success is claimed. See integration_test/discovery_journey_test.dart for measurement instrumentation and RUNBOOK for exact profile steps. Review the actual visual flow on tablet landscape/portrait and phone, large text and reduced motion before marking Phase 2 complete. Fix runtime findings in this implementation first. Session-memory shortlist and in-session Back restoration are deliberate boundaries; process-death restoration is not implemented.

## Exact Phase 3 starting point

After the Flutter acceptance checks, add intelligent search behind a separate search repository/provider interface and a documented backend endpoint. Search results should decode the existing ArtworkSummary model and invoke `approachArtwork` with unique search-result Hero tags; retain search query/result position when stepping back. Reuse publication filtering, safe structured filters, image renditions, explicit resources and Problem Details. Do not build a second artwork detail screen. Preserve all Phase 1/2 tests and the four collection experiences.

Plan semantic provider/indexing, degraded behavior and a small relevance evaluation separately; none currently exists. Continue deferring wall placement to Phase 4 and persisted guest shortlist/reservation to Phase 5. Do not infer production availability or real ownership from fictional sample editions/prices.


### Final source update — 16 October 2026

Initial GitHub CI stopped at formatting gates (Pint argument spacing and Dart entrance formatting), before Flutter analysis, tests or APK build. Those source formatting issues are corrected, and the navigation test now targets a stable artwork key. At the user’s request to minimise credits, no further suites or builds were run; the final source commit skips CI. Earlier backend evidence remains valid for the tested revision, but these final corrections have not received a fresh CI pass. Flutter/device acceptance remains pending; Phase 2 is implemented, not fully acceptance-verified.
