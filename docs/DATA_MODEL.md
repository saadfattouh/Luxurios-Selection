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
