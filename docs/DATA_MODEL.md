# Data model

All domain records have UUID primary keys and created_at/updated_at timestamps. UUIDs are stable public identifiers; slugs are navigation identifiers, unique where present. No personal collector data is stored.

| Entity | Relationships | Important fields |
|---|---|---|
| Exhibition | hero Artwork; many Artworks through artwork_exhibition | slug, EN/AR title/subtitle, published_at, position |
| Collection | many Artworks through artwork_collection | slug, EN/AR title, atmosphere, position |
| Artwork | Photographer; media; editions; many Collections/Exhibitions | slug, EN/AR title/story, published_at, is_curator_pick |
| ArtworkMedia | Artwork | disk/path, EN/AR alt, width/height, position, credit, source_url |
| Photographer | many Artworks | slug, EN/AR name/bio, is_featured |
| Edition | Artwork; many PrintSizeOptions | EN/AR label, is_limited, total |
| PrintSizeOption | many Editions | EN/AR label, physical width/height in millimetres |
| FrameOption | independent future configuration catalog | EN/AR label, material, color_hex, border_mm |
| RoomScene | independent future scene catalog | EN/AR label, nullable disk/path/wall_bounds |

Pivots use composite primary keys; artwork membership includes editorial position. Edition/print-size links have timestamps. Deletion cascades through owned media/editions/memberships; photographer deletion is restricted while works exist. Deleting an exhibition hero sets its reference to null. There are no deletion endpoints.

PostgreSQL CHECK constraints enforce positive media/print dimensions and consistent edition totals. A limited edition must have total > 0; an open edition must have a null total. No inventory, sold quantity, edition number, price, or availability promise is inferred from this foundation.

Frame/Room records have no selection relationships yet. RoomScene is intentionally seeded without an image or geometry; inventing uncalibrated physical wall data would create false precision. Phase 4 should define calibrated coordinates, compatible sizes/frames, and selected-configuration relationships.

## Development data

The repeatable seeder upserts fixed UUIDs, syncs membership pivots, and runs in a transaction. It only runs in local/testing. Six fictional works (using four reference-image variants), two exhibitions, four collection identities, one fictional photographer, six editions, one size, one frame, and one room placeholder are included. Running the seeder twice does not duplicate rows. It updates its own sample IDs and preserves unrelated data; it does not truncate the database.

Images are bundled and copied through the configured filesystem disk. The monochrome reference is a grayscale derivative of the mountain image. See MEDIA_CREDITS.md. Content publication dates are fixed in September 2026; tests fix the clock to September 18, 2026.

The bilingual schema is ready; Phase 1 UI labels remain English. Future Arabic UI needs translated chrome, locale persistence, RTL and typography verification.

## Phase 2 additions

Migration `2026_09_19_000001_add_discovery_metadata` is additive and reversible; existing UUIDs, memberships and Phase 1 migrations are unchanged.

- ArtworkMedia gains nullable JSONB `renditions` (stored paths/dimensions only) and nullable `dominant_color`. Public resources resolve URLs and never return disk/path fields. The source media record remains the source of alt text, aspect ratio and credit.
- Edition gains availability (default unknown), nullable starting_price_minor and currency. Database CHECKs allow only four availability states and require a nonnegative price and three-letter uppercase currency together, or both null. Existing rows do not silently become available or acquire a price.
- Indexes: artwork `(photographer_id,published_at,id)`; exhibition `(position,id,published_at)`; each membership pivot `(parent_id,artwork_id)`; edition `(artwork_id,availability,is_limited)`. Existing artwork UUID PK supports keyset ordering. Primary-media lookup already has `(artwork_id,position)` uniqueness. Slugs already have unique indexes.
- Relationships are reused: no redundant availability table, transaction flow or per-edition number is invented. Detail eager-loads editions.printSizes; streams load compact photographer/edition columns and one primary media record without story text.

The sample seeder retains all six IDs and four images. It now assigns explicit fictional prices in AED and one sold-out edition to demonstrate states. These are demo data only. Existing print-size summaries are indicative; aspect-ratio compatibility and pricing rules belong to Phase 4. Unknown data stays unknown for non-seeded records. `media:renditions` is idempotent for unchanged source bytes; old hashed rendition cleanup is deferred and must respect caches before deletion.
