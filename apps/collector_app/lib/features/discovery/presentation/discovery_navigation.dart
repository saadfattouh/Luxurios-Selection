import 'package:flutter/material.dart';
import '../../exhibition/data/models.dart';
import 'artwork_focus_view.dart';
import 'discovery_view.dart';

void openDiscovery(BuildContext context, String kind, String slug) {
  Navigator.of(context).push(
    _route(context, '/$kind/$slug', DiscoveryView(kind: kind, slug: slug), 520),
  );
}

Future<void> approachArtwork(
  BuildContext context,
  Artwork artwork,
  String tag, {
  int duration = 600,
}) async {
  await Navigator.of(context).push(
    _route(
      context,
      '/artworks/${artwork.id}',
      ArtworkFocusView(id: artwork.id, preview: artwork, heroTag: tag),
      duration,
    ),
  );
}

PageRoute<void> _route(
  BuildContext context,
  String name,
  Widget page,
  int duration,
) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return PageRouteBuilder<void>(
    settings: RouteSettings(name: name),
    transitionDuration: Duration(milliseconds: reduced ? 0 : duration),
    reverseTransitionDuration: Duration(milliseconds: reduced ? 0 : 420),
    pageBuilder: (context, animation, secondaryAnimation) => HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: page,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      // Secondary animation recedes the retained route on approach, reverses on Back.
      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.18).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 0.97).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          ),
        ),
      );
    },
  );
}
