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

## Phase 2 — discovery and focus

The Phase 1 responses and routes remain compatible. New endpoints:

| Method/path | Response | Publication / payload rules |
|---|---|---|
| GET /exhibitions/{slug}/artworks | Cursor-paginated ArtworkSummary[] | Parent and works must be published; no story/biography/configuration data |
| GET /collections/{slug} | Collection | Identity only: id, slug, localized title, atmosphere |
| GET /collections/{slug}/artworks | Cursor-paginated ArtworkSummary[] | Published works only; primary media only |
| GET /artworks/{UUID-or-slug} | Artwork | Story, photographer biography, media, editions with availability/price/sizes, collection identities |
| GET /photographers/{UUID-or-slug} | Photographer | 404 unless at least one artwork is publicly published |

`GET /exhibitions/{slug}` retains its Phase 1 published-hero behavior. Empty collections return 200 with an empty stream. Missing/draft/future artwork or exhibition returns 404 Problem Details. Normal UI data uses these APIs; no fixture fallback.

### Stable artwork paging and filters

Streams sort by immutable artwork UUID ascending, with a unique keyset cursor. This deliberately differs from the editable home editorial order. Pass `meta.next_cursor` back as `cursor`; null means the end. Responses also include `links` and `meta.per_page`, `path`, `prev_cursor`. No total-count query runs. `per_page` is 1–24 (default 12). Cursor values are opaque navigation tokens, not authorization tokens. A cursor is not a frozen catalog snapshot: newly inserted IDs before the current boundary appear on a fresh visit; deletions/publication/availability changes may remove items. Existing rows do not shift as with offset pagination. Reset the cursor when filters or parent change.

| Filter | Allowed values |
|---|---|
| orientation | landscape / portrait / square; compares width and height of primary media at position 0 |
| collection | collection slug |
| photographer | photographer UUID or slug |
| availability | available / sold_out / unavailable / unknown |
| edition_status | limited / open |

Filters combine with AND. Availability and edition status must match the same edition. Unsupported query keys, malformed cursors and invalid values return 422. There is no arbitrary sort, include, SQL, or search expression. Flutter currently exposes orientation, availability and edition type refinements. Parent collection/exhibition determines the stream; photographer and cross-collection filtering are also API-ready.

```http
GET /api/v1/exhibitions/beyond-the-horizon/artworks?per_page=2&collection=landscape&availability=available
```

Summary fields: id, slug, localized title, photographer identity/name (without bio), at most one media record, nullable edition_summary (is_limited and nullable total), and availability. No per-work detail requests happen during scrolling. Detail editions add `availability`, nullable `starting_price: {amount_minor, currency}`, and `sizes: [{id, label, width_mm, height_mm}]`. Sizes and prices are indicative; no physical configuration or inventory reservation is implied. Mixed unavailable edition states serialize summary availability as unknown; any available edition makes the summary available.

### Display media

Media preserves legacy `url`, width/height, alt, credit and source_url. Additive fields: aspect_ratio, nullable dominant_color (`#RRGGBB`), and `renditions` with optional thumbnail/hero/fullscreen objects, each containing url, width, height, aspect_ratio. Longest-edge caps are 480/1280/1920 pixels without upscaling or cropping. Alt text is localized at media level and applies to all renditions. The UI uses the dominant color while decoding and falls back to the legacy URL if renditions are absent.

Run `php artisan media:renditions` for existing public display media. The sample seeder builds them automatically. Generation is a CLI operation, never a read request. Files have content-hashed names. Public disk rendition URLs use the existing `/api/media/{path}` route with configured CORS; S3 uses the storage URL resolver. Legacy `/storage` URLs remain unchanged for compatibility. `/api/media` rejects traversal, arbitrary disks and non-image extensions. CORS is configured centrally rather than fixed to one origin.

### Public content revalidation

Successful v1 content GETs emit ETag based on the entire serialized body plus `Cache-Control: public, max-age=0, must-revalidate` and Vary Accept/Origin. `If-None-Match` returns bodyless 304 when unchanged, including when related editions/media are unchanged. This saves transfer, not database work. No shared response cache or stale inventory is introduced. Flutter currently fetches JSON normally; native/browser image caches handle media. The media route has a one-hour public cache. Health/readiness remain uncached.
