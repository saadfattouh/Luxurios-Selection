# Design system

The experience brief is binding. Photography carries color; interface chrome carries restraint. No cart, prices, crowded catalog cards, faux VR controls, neon or bouncing elements appear in Phase 1.

| Token | Value / role |
|---|---|
| Background | #101211 architectural charcoal |
| Surface | #1A1E1C quiet depth |
| Ink | #F0EEE6 warm high-contrast text |
| Muted | #B3B8AF supporting text |
| Accent | #C7B891 restrained warm metal |
| Divider | #3D443E |
| Glass | #CC1A1E1C reserved, not applied indiscriminately |
| Spacing unit | 8 logical pixels |
| Gutters | 64 ≥1000 wide; 40 ≥600; 24 phone |
| Radius | 4; minimal rounding |
| Touch | minimum 48; primary entrance button 56 high |
| Display | serif 68 desktop/tablet landscape, 40 compact |
| Body | 17/1.5 leading; supporting 14/1.5 |
| Depth | 48 blur, 28 vertical offset, no ambient animation |

Tokens live in `apps/collector_app/lib/design/tokens.dart`. System serif is used so the app has no font-network dependency; branded licensed fonts remain a visual refinement item.

Landscapes are shown with BoxFit.contain: the full photograph matters more than filling a card. Hero reference images have a 1600-pixel decode cap; mobile disk caching uses cached_network_image and web uses browser HTTP caching. Images show explicit loading and unavailable states.

Semantics label images with API alt text; identity and section headings are semantic headers. Error states are live regions. There is no hover-only interaction. All content can scroll, large text is not globally clamped, and system reduced-motion preferences are respected. Test targets: 1280×800, 800×1280, 390×844 at 1.6 text scale. These tests are authored, but have not run because Flutter execution is blocked.

Visual acceptance remains pending: no screenshot or rendered Flutter preview has been produced. Verify typography, media sizing, touch targets and TalkBack on an Android tablet before declaring the design approved.

## Phase 2 collection environments

All collections retain the same top Back/refine controls, horizontal swipe, directional buttons, approach action and progressive focus information. `CollectionAtmosphere` supplies controlled variants:

| Collection | Background / light | Tablet side spacing | Display treatment | Movement |
|---|---|---|---|---|
| Wildlife / atmospheric | #0E1813 / #2F4132 | 36 | Editorial serif, 2px tracking | 600ms |
| Architecture / geometric | #151719 / #33383B | 28 | Sans-serif artwork title, 3px tracking, static structural lines | 480ms |
| Landscape / expansive | #151E23 / #34464E | 64 | Editorial serif, 2px tracking, more negative space | 650ms |
| Black & White / monochrome | #111111 / #303030 | 40 | Restrained serif, 4px tracking | 520ms |

Phone image gutters reduce to 12px. Radial lighting is static; no moving room, camera, blur or ambient animation. The image occupies approximately 72% of the discovery viewport; each page can scroll vertically when text is enlarged. Focus uses a quiet #090B0A backdrop and an image approximately 73% of viewport height, then minimal title/artist/edition text. Story, biography, indicative sizes, availability and starting price appear only on request. The Phase 4 action is visibly disabled.

Empty/offline/detail failures, missing images, retry and large-text layouts are implemented. The existing image semantic labels remain; navigation uses 48px Material controls and keyboard-focusable InkWell/buttons. No visual sign-off or device/TalkBack result is claimed by these source changes.
