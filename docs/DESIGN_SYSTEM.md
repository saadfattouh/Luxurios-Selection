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
