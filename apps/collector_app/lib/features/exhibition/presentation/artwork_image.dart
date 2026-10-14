import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../data/models.dart';

class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.artwork,
    this.fit = BoxFit.contain,
    this.rendition = 'hero',
  });
  final Artwork? artwork;
  final BoxFit fit;
  final String rendition;
  @override
  Widget build(BuildContext context) {
    final media = artwork?.media.firstOrNull;
    if (media == null) return const ImageUnavailable();
    final cap = rendition == 'fullscreen'
        ? 1920
        : rendition == 'thumbnail'
        ? 480
        : 1280;
    final maxSide = media.width > media.height ? media.width : media.height;
    final decodeWidth = (media.width * (maxSide > cap ? cap / maxSide : 1))
        .round();
    final color = media.dominantColor;
    final placeholderColor =
        color != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(color)
        ? Color(int.parse('FF${color.substring(1)}', radix: 16))
        : ExhibitionTokens.surface;
    return Semantics(
      image: true,
      label: media.alt.en,
      child: ExcludeSemantics(
        child: CachedNetworkImage(
          imageUrl: media.urlFor(rendition),
          fit: fit,
          memCacheWidth: decodeWidth,
          fadeInDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          placeholder: (context, url) => ColoredBox(
            color: placeholderColor,
            child: const Center(
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
