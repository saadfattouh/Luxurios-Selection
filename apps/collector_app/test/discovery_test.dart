import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:collector_app/core/api_client.dart';
import 'package:collector_app/design/tokens.dart';
import 'package:collector_app/features/exhibition/data/models.dart';
import 'package:collector_app/features/discovery/data/discovery_repository.dart';
import 'package:collector_app/features/discovery/data/shortlist_repository.dart';
import 'package:collector_app/features/discovery/presentation/discovery_view.dart';
import 'package:collector_app/features/discovery/presentation/discovery_view_model.dart';
import 'package:collector_app/features/discovery/presentation/artwork_focus_view.dart';
import 'package:collector_app/features/discovery/presentation/atmosphere.dart';

Json artworkJson(int index) {
  final curation =
      jsonDecode(File('test/fixtures/curation.json').readAsStringSync())
          as Json;
  final art = Map<String, dynamic>.of(
    curation['data']['new_works'][index] as Json,
  );
  art['media'] =
      <dynamic>[]; // No external image requests in widget/layout tests.
  return art;
}

class DiscoveryFake implements DiscoveryRepository {
  DiscoveryFake({this.atmosphere = 'expansive'});
  final String atmosphere;
  int pages = 0;
  bool fail = false;
  bool empty = false;
  @override
  Future<CollectionIdentity> collection(String slug) async =>
      CollectionIdentity.fromJson({
        'slug': slug,
        'title': {'en': 'Collection', 'ar': ''},
        'atmosphere': atmosphere,
      });
  @override
  Future<Exhibition> exhibition(String slug) async => Exhibition.fromJson({
    'id': 'ex',
    'slug': slug,
    'title': {'en': 'Exhibition'},
    'subtitle': {},
    'hero_artwork': null,
  });
  @override
  Future<ArtworkPage> artworks(
    String kind,
    String slug, {
    String? cursor,
    Map<String, String> filters = const {},
  }) async {
    pages++;
    if (fail) throw const ApiFailure('Connection unavailable');
    return ArtworkPage.fromJson({
      'data': empty ? [] : [for (var i = 0; i < 3; i++) artworkJson(i)],
      'meta': {'next_cursor': null},
    });
  }

  @override
  Future<Artwork> artwork(String id) async {
    if (fail) throw const ApiFailure('Story unavailable');
    return [
      for (var i = 0; i < 3; i++) Artwork.fromJson(artworkJson(i)),
    ].firstWhere((a) => a.id == id);
  }

  @override
  Future<Photographer> photographer(String id) async =>
      (await artwork(artworkJson(0)['id'] as String)).photographer;
}

Widget harness(DiscoveryRepository repo, Widget home) => MultiProvider(
  providers: [
    Provider<DiscoveryRepository>.value(value: repo),
    ChangeNotifierProvider<ShortlistRepository>(
      create: (_) => MemoryShortlistRepository(),
    ),
  ],
  child: MaterialApp(theme: ExhibitionTokens.theme, home: home),
);

void main() {
  test(
    'repository encodes cursor and filters with the documented route',
    () async {
      final repo = ApiDiscoveryRepository(
        ApiClient(
          MockClient((request) async {
            expect(request.url.path, '/api/v1/collections/wildlife/artworks');
            expect(request.url.queryParameters['cursor'], 'cursor+/=');
            expect(request.url.queryParameters['orientation'], 'portrait');
            return http.Response(
              jsonEncode({
                'data': [],
                'meta': {'next_cursor': null},
              }),
              200,
            );
          }),
          Uri.parse('http://localhost/api/v1/'),
        ),
      );
      expect(
        (await repo.artworks(
          'collections',
          'wildlife',
          cursor: 'cursor+/=',
          filters: {'orientation': 'portrait'},
        )).items,
        isEmpty,
      );
    },
  );
  test(
    'late responses after filter changes cannot overwrite the current stream',
    () async {
      final repo = DeferredDiscovery();
      final vm = DiscoveryViewModel(repo, 'collections', 'landscape');
      final first = vm.load();
      await Future<void>.delayed(Duration.zero);
      final second = vm.filter({'orientation': 'portrait'});
      await Future<void>.delayed(Duration.zero);
      repo.requests[1].complete(
        ArtworkPage.fromJson({
          'data': [artworkJson(1)],
          'meta': {},
        }),
      );
      await second;
      repo.requests[0].complete(
        ArtworkPage.fromJson({
          'data': [artworkJson(0)],
          'meta': {},
        }),
      );
      await first;
      expect(vm.items.single.id, artworkJson(1)['id']);
      vm.dispose();
    },
  );
  test('shortlist interface retains and removes a saved artwork', () async {
    final repo = MemoryShortlistRepository();
    await repo.setSaved('a', true);
    expect(repo.contains('a'), isTrue);
    await repo.setSaved('a', false);
    expect(repo.contains('a'), isFalse);
    repo.dispose();
  });
  test(
    'view model recovers from offline and never reloads a terminal page',
    () async {
      final repo = DiscoveryFake()..fail = true;
      final vm = DiscoveryViewModel(repo, 'collections', 'landscape');
      await vm.load();
      expect(vm.error, isNotNull);
      repo.fail = false;
      await vm.load();
      expect(vm.items.length, 3);
      expect(vm.error, isNull);
      final calls = repo.pages;
      await vm.load();
      expect(repo.pages, calls);
      vm.dispose();
    },
  );
  for (final name in ['atmospheric', 'geometric', 'expansive', 'monochrome']) {
    for (final size in [const Size(1280, 800), const Size(390, 844)]) {
      testWidgets('$name collection atmosphere fits $size at large text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          harness(
            DiscoveryFake(atmosphere: name),
            const DiscoveryView(kind: 'collections', slug: 'collection'),
          ),
        );
        await tester.pumpAndSettle();
        final surface = tester.widget<AtmosphereSurface>(
          find.byType(AtmosphereSurface),
        );
        expect(
          surface.atmosphere.background,
          CollectionAtmosphere.forName(name).background,
        );
        expect(surface.atmosphere.geometric, name == 'geometric');
        expect(find.byType(PageView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final reduced in [false, true]) {
    testWidgets(
      'approach, reveal, shortlist, and Back restore exact page (reduced=$reduced)',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final repo = DiscoveryFake();
        await tester.pumpWidget(
          harness(
            repo,
            const DiscoveryView(kind: 'collections', slug: 'landscape'),
          ),
        );
        await tester.pumpAndSettle();
        final pager = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        pager.jumpToPage(1);
        await tester.pumpAndSettle();
        final previous = pager.page;
        final art = Artwork.fromJson(artworkJson(1));
        await tester.tap(find.bySemanticsLabel('Approach ${art.title.en}'));
        await tester.pumpAndSettle();
        expect(find.byType(ArtworkFocusView), findsOneWidget);
        await tester.tap(find.byTooltip('Save to shortlist'));
        await tester.pump();
        expect(find.byTooltip('Remove from shortlist'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('reveal-story')));
        await tester.tap(find.byKey(const Key('reveal-story')));
        await tester.pumpAndSettle();
        expect(find.text(art.story.en), findsOneWidget);
        await tester.ensureVisible(find.text('Step away'));
        await tester.tap(find.text('Step away'));
        await tester.pumpAndSettle();
        expect(pager.page, previous);
        expect(repo.pages, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('empty and offline states retry without substituting fixtures', (
    tester,
  ) async {
    final repo = DiscoveryFake()..fail = true;
    await tester.pumpWidget(
      harness(repo, const DiscoveryView(kind: 'collections', slug: 'wildlife')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connection unavailable'), findsOneWidget);
    repo.fail = false;
    repo.empty = true;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      find.text('A quiet space, awaiting its next photographs.'),
      findsOneWidget,
    );
  });
  testWidgets('partial detail and missing image remain navigable', (
    tester,
  ) async {
    final preview = Artwork.fromJson(artworkJson(0));
    final repo = DiscoveryFake()..fail = true;
    await tester.pumpWidget(
      harness(
        repo,
        ArtworkFocusView(id: preview.id, heroTag: 'test', preview: preview),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(preview.title.en), findsOneWidget);
    expect(find.text('Photograph unavailable'), findsOneWidget);
    expect(find.text('Story unavailable'), findsOneWidget);
    expect(find.text('Step away'), findsOneWidget);
  });
}

class DeferredDiscovery extends DiscoveryFake {
  final List<Completer<ArtworkPage>> requests = [];
  @override
  Future<ArtworkPage> artworks(
    String kind,
    String slug, {
    String? cursor,
    Map<String, String> filters = const {},
  }) {
    final pending = Completer<ArtworkPage>();
    requests.add(pending);
    return pending.future;
  }
}
