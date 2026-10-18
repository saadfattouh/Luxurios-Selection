import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design/tokens.dart';
import '../../exhibition/presentation/artwork_image.dart';
import '../../exhibition/presentation/entrance_view.dart';
import '../data/discovery_repository.dart';
import 'atmosphere.dart';
import 'discovery_navigation.dart';
import 'discovery_view_model.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key, required this.kind, required this.slug});
  final String kind;
  final String slug;
  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  late DiscoveryViewModel vm;
  final controller = PageController(viewportFraction: 0.9, keepPage: true);
  String? _prefetched;
  @override
  void initState() {
    super.initState();
    vm = DiscoveryViewModel(
      context.read<DiscoveryRepository>(),
      widget.kind,
      widget.slug,
    );
    vm.addListener(_changed);
    vm.load();
  }

  void _changed() {
    if (mounted) {
      setState(() {});
      _prefetchNext();
    }
  }

  void _prefetchNext() {
    final next = vm.index + 1;
    if (next >= vm.items.length) return;
    final media = vm.items[next].media.firstOrNull;
    if (media == null) return;
    final url = media.urlFor('hero');
    final longestSide = media.width > media.height ? media.width : media.height;
    final decodeWidth =
        (media.width * (longestSide > 1280 ? 1280 / longestSide : 1)).round();
    if (url == _prefetched) return;
    _prefetched = url;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        precacheImage(
          ResizeImage(CachedNetworkImageProvider(url), width: decodeWidth),
          context,
          onError: (_, stack) {},
        );
    });
  }

  @override
  void dispose() {
    vm.removeListener(_changed);
    vm.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _filters() async {
    final selected = Map<String, String>.of(vm.filters);
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refine your visit',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                for (final entry in <String, List<String>>{
                  'orientation': ['landscape', 'portrait', 'square'],
                  'availability': [
                    'available',
                    'sold_out',
                    'unavailable',
                    'unknown',
                  ],
                  'edition_status': ['limited', 'open'],
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: selected[entry.key] ?? '',
                      decoration: InputDecoration(
                        labelText: entry.key.replaceAll('_', ' '),
                      ),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All')),
                        ...entry.value.map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.replaceAll('_', ' ')),
                          ),
                        ),
                      ],
                      onChanged: (value) => update(() {
                        if (value == null || value.isEmpty) {
                          selected.remove(entry.key);
                        } else {
                          selected[entry.key] = value;
                        }
                      }),
                    ),
                  ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Continue exploring'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, <String, String>{}),
                  child: const Text('Clear refinements'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (controller.hasClients) controller.jumpToPage(0);
    await vm.filter(result);
  }

  @override
  Widget build(BuildContext context) {
    final atmosphere = CollectionAtmosphere.forName(vm.atmosphere);
    return Scaffold(
      body: AtmosphereSurface(
        atmosphere: atmosphere,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back to exhibition',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        vm.title.isEmpty ? 'The exhibition' : vm.title,
                        style: TextStyle(
                          color: ExhibitionTokens.ink,
                          letterSpacing: atmosphere.tracking,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refine collection',
                      onPressed: _filters,
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ),
              ),
              if (vm.filters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    vm.filters.values
                        .map((v) => v.replaceAll('_', ' '))
                        .join(' · '),
                  ),
                ),
              Expanded(
                child: vm.items.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: vm.loading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 1,
                                  )
                                : vm.error != null
                                ? LoadError(
                                    message: vm.error!,
                                    onRetry: () => vm.load(reset: true),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'A quiet space, awaiting its next photographs.',
                                        textAlign: TextAlign.center,
                                      ),
                                      if (vm.filters.isNotEmpty)
                                        TextButton(
                                          onPressed: () => vm.filter({}),
                                          child: const Text(
                                            'Clear refinements',
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      )
                    : PageView.builder(
                        key: PageStorageKey(
                          'discovery-${widget.kind}-${widget.slug}',
                        ),
                        controller: controller,
                        itemCount:
                            vm.items.length + (vm.nextCursor != null ? 1 : 0),
                        onPageChanged: (index) {
                          setState(() => vm.index = index);
                          _prefetchNext();
                          if (index >= vm.items.length - 2) vm.load();
                        },
                        itemBuilder: (context, index) {
                          if (index == vm.items.length)
                            return Center(
                              child: vm.error != null
                                  ? LoadError(
                                      message: vm.error!,
                                      onRetry: vm.load,
                                    )
                                  : const CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
                            );
                          final art = vm.items[index];
                          final tag = '${widget.kind}/${widget.slug}/${art.id}';
                          return LayoutBuilder(
                            builder: (context, box) => SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: box.maxWidth < 600
                                      ? 12
                                      : atmosphere.margin,
                                  vertical: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: 'Approach ${art.title.en}',
                                      child: InkWell(
                                        key: Key('approach-${art.id}'),
                                        onTap: () => approachArtwork(
                                          context,
                                          art,
                                          tag,
                                          duration: atmosphere.duration,
                                        ),
                                        child: Hero(
                                          tag: tag,
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: (box.maxHeight * 0.72)
                                                .clamp(180.0, 820.0),
                                            child: ArtworkImage(
                                              artwork: art,
                                              rendition: 'hero',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      art.title.en,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontFamily: atmosphere.geometric
                                                ? 'sans-serif'
                                                : 'serif',
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(art.photographer.name.en),
                                    TextButton(
                                      onPressed: () => approachArtwork(
                                        context,
                                        art,
                                        tag,
                                        duration: atmosphere.duration,
                                      ),
                                      child: const Text(
                                        'Approach photograph  →',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (vm.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Previous photograph',
                        onPressed: vm.index > 0
                            ? () => _move(vm.index - 1, atmosphere)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '${(vm.index + 1).clamp(1, vm.items.length)} / ${vm.items.length}${vm.nextCursor != null ? '+' : ''}  ·  Swipe to explore',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next photograph',
                        onPressed:
                            vm.index < vm.items.length - 1 ||
                                vm.nextCursor != null
                            ? () => _move(vm.index + 1, atmosphere)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _move(int index, CollectionAtmosphere atmosphere) {
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpToPage(index);
    } else {
      controller.animateToPage(
        index,
        duration: Duration(milliseconds: atmosphere.duration),
        curve: Curves.easeOutCubic,
      );
    }
  }
}
