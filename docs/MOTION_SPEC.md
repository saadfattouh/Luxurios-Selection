# Motion specification

## Entrance

Identity remains static while the API loads. A bounded curation response supplies the hero, title and subtitle. Once data is available, an 1800ms controller reveals the photograph with easeOutCubic opacity and a small 1.025→1 scale change. At 30% of the sequence, editorial text fades in with a maximum 12px upward movement. The environment uses a static radial light gradient and image shadow; no animated blur or real-time 3D is used.

Enter Exhibition is a real route action. A 650ms fade accompanies a shared Hero (`entrance-artwork`) into the home. The home uses the same first exhibition/hero identity to avoid switching images midway. Returning to the entrance does not replay the initial reveal. There is no auto-navigation or required waiting timer.

## Reduced motion

System disableAnimations reveals entrance content immediately and removes route fade. Shared hero motion must be visually verified on a device; Flutter Hero behavior is additionally disabled with HeroMode when reduced motion is active. No parallax is necessary in this milestone. Readable content and navigation remain identical.

## Performance acceptance (pending)

Measure on the target Android tablet in profile mode: no sustained frame misses during entrance, no repeated HTTP loads from rebuilds, bounded image memory, no animation when offscreen. Decode cap is 1600px. There are no repeating decorative animations. This source has not been profiled or visually verified in the current environment.
