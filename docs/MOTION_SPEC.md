# Motion specification

## Entrance

Identity remains static while the API loads. A bounded curation response supplies the hero, title and subtitle. Once data is available, an 1800ms controller reveals the photograph with easeOutCubic opacity and a small 1.025→1 scale change. At 30% of the sequence, editorial text fades in with a maximum 12px upward movement. The environment uses a static radial light gradient and image shadow; no animated blur or real-time 3D is used.

Enter Exhibition is a real route action. A 650ms fade accompanies a shared Hero (`entrance-artwork`) into the home. The home uses the same first exhibition/hero identity to avoid switching images midway. Returning to the entrance does not replay the initial reveal. There is no auto-navigation or required waiting timer.

## Reduced motion

System disableAnimations reveals entrance content immediately and removes route fade. Shared hero motion must be visually verified on a device; Flutter Hero behavior is additionally disabled with HeroMode when reduced motion is active. No parallax is necessary in this milestone. Readable content and navigation remain identical.

## Performance acceptance (pending)

Measure on the target Android tablet in profile mode: no sustained frame misses during entrance, no repeated HTTP loads from rebuilds, bounded image memory, no animation when offscreen. Decode cap is 1600px. There are no repeating decorative animations. This source has not been profiled or visually verified in the current environment.

## Phase 2 — approaching and stepping away

1. A gallery tap pushes a real focus route; a Hero tag `parent-kind/slug/artwork-id` pairs the selected photograph. Home uses `home/section/artwork-id`. The hero starts with the same hero rendition, BoxFit.contain and aspect ratio; no crop/rotation is applied.
2. Route entry opacity follows easeOutCubic from 0→1. Collection-specific duration is Wildlife 600ms, Architecture 480ms, Landscape 650ms and Black & White 520ms. Home approach defaults to 600ms. Shared-element bounds use Flutter's standard Hero MaterialRectArcTween within this route duration.
3. On gallery secondaryAnimation, the retained environment recedes with uniform scale 1→0.97 and opacity 1→0.18, easeOutCubic. No perspective tilt, artificial camera movement or animated blur. Hero is rendered in the Navigator overlay and remains the focus as surrounding works recede.
4. Focus title/photographer/edition arrive with the route fade. At 700ms from focus creation, the image may request the fullscreen rendition; its cache fade is 150ms. This timer does not delay input or API retrieval and is cancelled on disposal. The gallery never prefetches fullscreen images.
5. Story & edition toggles an AnimatedSize expansion, 240ms easeOutCubic. Photographer biography expands inside that information section. All content scrolls rather than clipping enlarged text.
6. Back button, Android system Back or a Back during approach pops the same route. Reverse duration is 420ms. The Hero returns to its source slot, the environment restores scale/opacity, and the retained gallery controller keeps its offset and filters. No return API request, entrance replay, auto-advance or forced waiting interval. A cancelled approach has no inventory or server mutation.
7. Gallery next/previous buttons use the atmosphere duration with easeOutCubic. Direct touch scrolling follows the user's finger and native PageView settling. Filter changes reset the gallery to page zero. Entering a collection from home fades over 520ms.

Reduced motion: HeroMode off, route duration/reverse duration zero, no receding scale/fade, gallery buttons jump to page, image fade zero and story size duration zero. Content, controls and navigation outcomes remain identical. These are implemented equivalents; transition smoothness still requires profile-mode acceptance on Android.
