import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design/tokens.dart';
import '../data/models.dart';
import 'artwork_image.dart';
import 'entrance_view.dart';
import 'exhibition_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExhibitionViewModel>();
    final data = vm.curation;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final gutter = ExhibitionTokens.gutter(width);
            final hero = data?.exhibitions.firstOrNull;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Identity()),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entrance'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    if (vm.loading)
                      const Center(child: CircularProgressIndicator()),
                    if (vm.error != null)
                      LoadError(message: vm.error!, onRetry: vm.load),
                    if (data != null) ...[
                      const Eyebrow('THE EXHIBITION / 01'),
                      const SizedBox(height: 12),
                      Text(
                        'A different way to see.',
                        style: width >= 900
                            ? Theme.of(context).textTheme.displayLarge
                            : Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 32),
                      if (hero != null)
                        Hero(
                          tag: 'entrance-artwork',
                          child: SizedBox(
                            width: double.infinity,
                            height: width >= 900 ? 430 : 280,
                            child: ArtworkImage(artwork: hero.hero),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (hero != null)
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            Text(
                              hero.title.en,
                              style: const TextStyle(
                                color: ExhibitionTokens.ink,
                              ),
                            ),
                            Text(hero.subtitle.en),
                          ],
                        ),
                      const SectionHeading('Current Exhibitions', number: '01'),
                      ...data.exhibitions.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title.en,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(e.subtitle.en),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: data.collections
                            .map(
                              (c) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ExhibitionTokens.line,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    ExhibitionTokens.radius,
                                  ),
                                ),
                                child: Text(c.title.en),
                              ),
                            )
                            .toList(),
                      ),
                      const SectionHeading('Curator’s Selection', number: '02'),
                      ArtworkSequence(
                        artworks: data.curatorsSelection,
                        availableWidth: width - gutter * 2,
                      ),
                      const SectionHeading(
                        'New Photographic Works',
                        number: '03',
                      ),
                      ArtworkSequence(
                        artworks: data.newWorks,
                        availableWidth: width - gutter * 2,
                      ),
                      const SectionHeading(
                        'Featured Photographer',
                        number: '04',
                      ),
                      if (data.featuredPhotographer
                          case final Photographer photographer)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(width < 600 ? 24 : 48),
                          decoration: const BoxDecoration(
                            color: ExhibitionTokens.surface,
                            border: Border(
                              left: BorderSide(
                                color: ExhibitionTokens.accent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('IN CONVERSATION WITH LIGHT'),
                              const SizedBox(height: 20),
                              Text(
                                photographer.name.en,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge,
                              ),
                              const SizedBox(height: 20),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: Text(
                                  photographer.bio.en,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SectionHeading('Limited Editions', number: '05'),
                      ArtworkSequence(
                        artworks: data.limitedEditions,
                        availableWidth: width - gutter * 2,
                        editions: true,
                      ),
                      const SizedBox(height: 80),
                      const Divider(color: ExhibitionTokens.line),
                      const SizedBox(height: 24),
                      const Text(
                        'A private perspective. A lasting impression.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Demonstration collection · Fictional artists and works · Reference imagery from Unsplash',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, required this.number});
  final String title;
  final String number;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 72, bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: ExhibitionTokens.line),
        const SizedBox(height: 20),
        Eyebrow(number),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
      ],
    ),
  );
}

class ArtworkSequence extends StatelessWidget {
  const ArtworkSequence({
    super.key,
    required this.artworks,
    required this.availableWidth,
    this.editions = false,
  });
  final List<Artwork> artworks;
  final double availableWidth;
  final bool editions;
  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) return const Text('New works are being prepared.');
    // A curated horizontal sequence on tablets; a generous single column on phones.
    final tablet = availableWidth >= 620;
    final imageWidth = tablet
        ? (availableWidth * 0.63).clamp(360.0, 720.0)
        : availableWidth;
    Widget panel(Artwork a) => SizedBox(
      width: imageWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1.6, child: ArtworkImage(artwork: a)),
          const SizedBox(height: 20),
          Text(a.title.en, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            editions && a.editionTotal != null
                ? 'Edition of ${a.editionTotal}  ·  ${a.photographer.name.en}'
                : a.photographer.name.en,
          ),
        ],
      ),
    );
    if (!tablet)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: artworks
            .map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: panel(a),
              ),
            )
            .toList(),
      );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: artworks
            .map(
              (a) => Padding(
                padding: const EdgeInsets.only(right: 40),
                child: panel(a),
              ),
            )
            .toList(),
      ),
    );
  }
}
