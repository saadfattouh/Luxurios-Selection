import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../data/models.dart';

class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.artwork,
    this.fit = BoxFit.contain,
  });
  final Artwork? artwork;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    final media = artwork?.media.firstOrNull;
    if (media == null) return const ImageUnavailable();
    return Semantics(
      image: true,
      label: media.alt.en,
      child: ExcludeSemantics(
        child: CachedNetworkImage(
          imageUrl: media.url,
          fit: fit,
          memCacheWidth: 1600,
          placeholder: (context, url) => const ColoredBox(
            color: ExhibitionTokens.surface,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
          ),
          errorWidget: (context, url, error) => const ImageUnavailable(),
        ),
      ),
    );
  }
}

class ImageUnavailable extends StatelessWidget {
  const ImageUnavailable({super.key});
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: ExhibitionTokens.surface,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Photograph unavailable', textAlign: TextAlign.center),
      ),
    ),
  );
}
