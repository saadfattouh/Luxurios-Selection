import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design/tokens.dart';
import 'artwork_image.dart';
import 'exhibition_view_model.dart';

class EntranceView extends StatefulWidget {
  const EntranceView({super.key});
  @override
  State<EntranceView> createState() => _EntranceViewState();
}

class _EntranceViewState extends State<EntranceView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: ExhibitionTokens.reveal,
  );
  bool _started = false;
  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExhibitionViewModel>();
    final exhibition = vm.curation?.exhibitions.firstOrNull;
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (exhibition != null && !_started) {
      _started = true;
      if (reduced) {
        _reveal.value = 1;
      } else {
        _reveal.forward();
      }
    }
    if (reduced && _started && _reveal.value != 1) _reveal.value = 1;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 900;
            final gutter = ExhibitionTokens.gutter(box.maxWidth);
            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.5, -0.3),
                  radius: 1.1,
                  colors: [Color(0xFF303A32), ExhibitionTokens.background],
                ),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Identity(),
                        const SizedBox(height: 48),
                        if (vm.loading)
                          const SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 1),
                            ),
                          ),
                        if (vm.error != null)
                          LoadError(message: vm.error!, onRetry: vm.load),
                        if (!vm.loading &&
                            vm.error == null &&
                            exhibition == null)
                          LoadError(
                            message: 'A new exhibition is being prepared.',
                            onRetry: vm.load,
                          ),
                        if (exhibition != null)
                          AnimatedBuilder(
                            animation: _reveal,
                            builder: (context, child) {
                              final imageT = Curves.easeOutCubic.transform(
                                _reveal.value,
                              );
                              final textT = const Interval(
                                0.3,
                                1,
                                curve: Curves.easeOut,
                              ).transform(_reveal.value);
                              final photograph = Opacity(
                                opacity: imageT,
                                child: Transform.scale(
                                  scale: 1.025 - imageT * 0.025,
                                  child: Hero(
                                    tag: 'entrance-artwork',
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        boxShadow: [ExhibitionTokens.depth],
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.42,
                                        child: ArtworkImage(
                                          artwork: exhibition.hero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              final editorial = Opacity(
                                opacity: textT,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    reduced ? 0 : 12 * (1 - textT),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Eyebrow(
                                        'A PRIVATE PHOTOGRAPHIC EXPERIENCE',
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        exhibition.title.en,
                                        style: wide
                                            ? Theme.of(context)
                                                  .textTheme
                                                  .displayLarge
                                            : Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        exhibition.subtitle.en,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      const SizedBox(height: 40),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context)
                                                .pushNamed('/exhibition'),
                                        child: const Text(
                                          'Enter Exhibition  →',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              return wide
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 30,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 4, child: editorial),
                                          const SizedBox(width: 56),
                                          Expanded(flex: 6, child: photograph),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        photograph,
                                        const SizedBox(height: 40),
                                        editorial,
                                      ],
                                    );
                            },
                          ),
                        const SizedBox(height: 56),
                        const Divider(color: ExhibitionTokens.line),
                        const SizedBox(height: 20),
                        const Wrap(
                          spacing: 32,
                          runSpacing: 12,
                          children: [
                            Eyebrow('LUXURIOUS SELECTION'),
                            Text('Photography. Given space.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Identity extends StatelessWidget {
  const Identity({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Row(
      children: [
        Icon(Icons.crop_free, color: ExhibitionTokens.accent, size: 28),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            'LUXURIOUS\nSELECTION',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 3,
              height: 1.5,
              color: ExhibitionTokens.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 2.2,
      height: 1.6,
      color: ExhibitionTokens.accent,
    ),
  );
}

class LoadError extends StatelessWidget {
  const LoadError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 64),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
