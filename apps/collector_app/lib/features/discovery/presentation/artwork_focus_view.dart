import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api_client.dart';
import '../../../design/tokens.dart';
import '../../exhibition/data/models.dart';
import '../../exhibition/presentation/artwork_image.dart';
import '../../exhibition/presentation/entrance_view.dart';
import '../data/discovery_repository.dart';
import '../data/shortlist_repository.dart';

class ArtworkFocusView extends StatefulWidget {
  const ArtworkFocusView({
    super.key,
    required this.id,
    required this.heroTag,
    this.preview,
  });
  final String id;
  final String heroTag;
  final Artwork? preview;
  @override
  State<ArtworkFocusView> createState() => _ArtworkFocusViewState();
}

class _ArtworkFocusViewState extends State<ArtworkFocusView> {
  Artwork? detail;
  String? error;
  bool loading = false;
  bool revealed = false;
  bool fullResolution = false;
  bool saving = false;
  Timer? upgrade;
  @override
  void initState() {
    super.initState();
    _load();
    upgrade = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => fullResolution = true);
    });
  }

  @override
  void dispose() {
    upgrade?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final value = await context.read<DiscoveryRepository>().artwork(
        widget.id,
      );
      if (mounted) setState(() => detail = value);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    } on Object {
      if (mounted)
        setState(() => error = 'The story is temporarily unavailable.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save(ShortlistRepository shortlist) async {
    setState(() => saving = true);
    try {
      await shortlist.setSaved(widget.id, !shortlist.contains(widget.id));
    } on Object {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your shortlist could not be updated. Please try again.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final art = detail ?? widget.preview;
    final shortlist = context.watch<ShortlistRepository>();
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF090B0A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final gutter = ExhibitionTokens.gutter(box.maxWidth);
            return SingleChildScrollView(
              key: PageStorageKey('focus-${widget.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Step away'),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: shortlist.contains(widget.id)
                              ? 'Remove from shortlist'
                              : 'Save to shortlist',
                          onPressed: saving ? null : () => _save(shortlist),
                          icon: Icon(
                            shortlist.contains(widget.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: widget.heroTag,
                    child: SizedBox(
                      height: (box.maxHeight * 0.73).clamp(220.0, 1100.0),
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: box.maxWidth < 600 ? 12 : 32,
                        ),
                        child: ArtworkImage(
                          artwork: art,
                          rendition: fullResolution ? 'fullscreen' : 'hero',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          art?.title.en ?? 'A closer look',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        if (art != null) Text(art.photographer.name.en),
                        const SizedBox(height: 12),
                        if (art?.editionTotal != null)
                          Text(
                            'Edition of ${art!.editionTotal}',
                            style: const TextStyle(
                              color: ExhibitionTokens.accent,
                            ),
                          ),
                        if (loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: LinearProgressIndicator(minHeight: 1),
                          ),
                        if (error != null)
                          LoadError(message: error!, onRetry: _load),
                        if (detail != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            key: const Key('reveal-story'),
                            onPressed: () =>
                                setState(() => revealed = !revealed),
                            icon: Icon(revealed ? Icons.remove : Icons.add),
                            label: Text(
                              revealed
                                  ? 'Let the photograph speak'
                                  : 'Story & edition',
                            ),
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: reduced ? 0 : 240),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topLeft,
                            child: revealed
                                ? _information(detail!)
                                : const SizedBox(width: double.infinity),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const OutlinedButton(
                          onPressed: null,
                          child: Text(
                            'Experience in Your Space · Phase 4 preview',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _information(Artwork art) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          art.story.en.isEmpty
              ? 'The curatorial story is being prepared.'
              : art.story.en,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ExpansionTile(
          expansionAnimationStyle: MediaQuery.disableAnimationsOf(context)
              ? AnimationStyle.noAnimation
              : null,
          tilePadding: EdgeInsets.zero,
          title: Text('About ${art.photographer.name.en}'),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  art.photographer.bio.en.isEmpty
                      ? 'The photographer profile is being prepared.'
                      : art.photographer.bio.en,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (art.editions.isEmpty)
          const Text('Edition information is being prepared.'),
        for (final edition in art.editions)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edition.label.en,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  edition.limited
                      ? 'Limited edition${edition.total == null ? '' : ' of ${edition.total}'}'
                      : 'Open edition',
                ),
                const SizedBox(height: 8),
                Text(switch (edition.availability) {
                  'available' => 'Available',
                  'sold_out' => 'Edition sold out',
                  'unavailable' => 'Currently unavailable',
                  _ => 'Availability on request',
                }),
                if (edition.sizes.isNotEmpty)
                  Text(edition.sizes.map((s) => s.en).join(' · ')),
                if (edition.priceMinor != null)
                  Text(
                    'Starting at ${edition.currency} ${(edition.priceMinor! / 100).toStringAsFixed(2)} · Indicative',
                  ),
              ],
            ),
          ),
        if (art.media.isNotEmpty)
          Text(
            art.media.first.alt.en,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    ),
  );
}
