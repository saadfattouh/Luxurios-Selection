import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:collector_app/core/api_client.dart';
import 'package:collector_app/core/environment.dart';
import 'package:collector_app/features/discovery/data/discovery_repository.dart';
import 'package:collector_app/features/discovery/presentation/artwork_focus_view.dart';
import 'package:collector_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('live discovery, detail, Back and profile measurements', (
    tester,
  ) async {
    final frames = <FrameTiming>[];
    void record(List<FrameTiming> values) => frames.addAll(values);
    SchedulerBinding.instance.addTimingsCallback(record);
    addTearDown(() => SchedulerBinding.instance.removeTimingsCallback(record));
    final watch = Stopwatch()..start();
    app.main();
    bool photographReady() => find
        .byType(RawImage)
        .evaluate()
        .any((e) => (e.widget as RawImage).image != null);
    for (var i = 0; i < 60 && !photographReady(); i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(photographReady(), isTrue);
    final firstArtworkMs = watch.elapsedMilliseconds;
    await tester.ensureVisible(find.text('Enter Exhibition  →'));
    await tester.tap(find.text('Enter Exhibition  →'));
    await tester.pump(const Duration(seconds: 2));
    await tester.ensureVisible(find.text('Landscape'));
    await tester.tap(find.text('Landscape'));
    for (var i = 0; i < 30 && find.byType(PageView).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final page = tester.widget<PageView>(find.byType(PageView)).controller!;
    page.jumpToPage(1);
    await tester.pump(const Duration(seconds: 1));
    final before = page.page;
    final approach = find.text('Approach photograph  →').hitTestable();
    await tester.ensureVisible(approach.first);
    await tester.tap(approach.first);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(ArtworkFocusView), findsOneWidget);
    for (
      var i = 0;
      i < 30 && find.byKey(const Key('reveal-story')).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.ensureVisible(find.byKey(const Key('reveal-story')));
    await tester.tap(find.byKey(const Key('reveal-story')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Starting at AED'), findsWidgets);
    await tester.ensureVisible(find.text('Step away'));
    await tester.tap(find.text('Step away'));
    await tester.pump(const Duration(seconds: 1));
    expect(page.page, before);
    for (var i = 0; i < 10; i++) {
      page.animateToPage(
        i % 2,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
      await tester.pump(const Duration(milliseconds: 750));
    }
    final client = http.Client();
    addTearDown(client.close);
    final api = ApiDiscoveryRepository(ApiClient(client, Environment.apiUri));
    final filtered = await api.artworks(
      'exhibitions',
      'beyond-the-horizon',
      filters: {'collection': 'landscape', 'availability': 'available'},
    );
    expect(filtered.items.length, 2);
    await expectLater(api.artwork('missing-work'), throwsA(isA<ApiFailure>()));
    final build =
        frames.map((f) => f.buildDuration.inMicroseconds / 1000).toList()
          ..sort();
    final raster =
        frames.map((f) => f.rasterDuration.inMicroseconds / 1000).toList()
          ..sort();
    binding.reportData = {
      'first_meaningful_artwork_ms': firstArtworkMs,
      'frames': frames.length,
      'build_p90_ms': build.isEmpty
          ? null
          : build[((build.length - 1) * 0.9).round()],
      'raster_p90_ms': raster.isEmpty
          ? null
          : raster[((raster.length - 1) * 0.9).round()],
      'frames_over_16_67_ms': frames
          .where(
            (f) =>
                f.buildDuration.inMicroseconds > 16670 ||
                f.rasterDuration.inMicroseconds > 16670,
          )
          .length,
      'image_cache_bytes': PaintingBinding.instance.imageCache.currentSizeBytes,
      'live_images': PaintingBinding.instance.imageCache.liveImageCount,
      'note':
          'Image cache is not whole-process memory. Capture adb dumpsys meminfo separately; record device, refresh rate and network.',
    };
  });
}
