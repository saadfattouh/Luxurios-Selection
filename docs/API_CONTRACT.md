# API contract — v1

Canonical machine-readable contract: `openapi.json` (OpenAPI 3.0.3). Full captured seeded response: `evidence/curation.json`.

Base path `/api/v1`. Public read-only access. Responses serialize explicit API Resources; database fields are not exposed implicitly. Both English and Arabic display values use `{ "en": "...", "ar": "..." }`. UUIDs are opaque identifiers. Dates use ISO 8601 UTC. Consumers must tolerate null hero_artwork and featured_photographer, empty sections, and additive fields.

| Method/path | Success payload | Behavior |
|---|---|---|
| GET /exhibitions | data[], links, meta | Published exhibitions, editorial position then ID |
| GET /exhibitions/{slug} | data Exhibition | 404 for missing, draft or future exhibition |
| GET /collections | data[], links, meta | Collection identities, editorial order |
| GET /home/curation | data Curation | Bounded snapshot; each section ≤6 entries |
| GET /health | data status/service/version | Process liveness; no DB dependency |
| GET /ready | data status | DB readiness; 503 Problem on failure |

## Requests and pagination

```http
GET /api/v1/exhibitions?per_page=1&page=1
Accept: application/json
```

Index responses carry Laravel's pagination `links` and `meta` fields. page is integer 1–100000, per_page is 1–24 (default 12). Invalid parameters return 422. Out-of-range valid pages return empty data. There is no client-supplied sort or arbitrary include clause.

Curation is intentionally not a growing catalog endpoint: each section is capped at six, with section_limit=6. Phase 2 should expose paginated artwork discovery; the home must not grow unbounded. In the seed there are 2 current exhibitions, 3 curator works, 6 new works, 1 featured photographer, 6 limited-edition works and 4 collection identities.

## Example content

```json
{
  "data": {
    "id": "00000000-0000-4000-8000-000000000500",
    "slug": "beyond-the-horizon",
    "title": {"en": "Beyond the horizon", "ar": "ما وراء الأفق"},
    "subtitle": {"en": "On distance, light, and the art of being still.", "ar": "عن المسافة والضوء وفن السكون."},
    "hero_artwork": null
  }
}
```

This is a valid minimal exhibition response when no published hero exists. In the seeded response hero_artwork is an Artwork containing id, slug, localized title/story, published_at, photographer, media[], editions[]. Media has a stable Storage-generated url plus dimensions, localized alt, credit and source_url. The real full snapshot provides the populated example, rather than using ellipses as invalid JSON.

```json
{"data":{"status":"ok","service":"luxurious-selection","version":"v1"}}
```

## Error contract

Every application error returns application/problem+json with type, title, status, detail, instance and request_id. Validation adds errors. Response headers carry X-Request-ID; rate limiting returns 429 and preserves Retry-After. Server details are hidden even when debug is accidentally enabled in configuration.

```json
{
  "type": "about:blank",
  "title": "Unprocessable Content",
  "status": 422,
  "detail": "One or more query parameters are invalid.",
  "instance": "/api/v1/exhibitions",
  "request_id": "example-request-id",
  "errors": {"per_page": ["The per page field must not be greater than 24."]}
}
```

The exact status title comes from the HTTP library and can vary between compatible versions; clients should branch on status/errors. Missing routes and models use 404; unsupported methods 405; readiness failure 503; unexpected errors 500. No stack traces are serialized.
