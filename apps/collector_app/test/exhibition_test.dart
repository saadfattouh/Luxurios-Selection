import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:collector_app/core/api_client.dart';
import 'package:collector_app/features/exhibition/data/exhibition_repository.dart';
import 'package:collector_app/features/exhibition/data/models.dart';
import 'package:collector_app/features/exhibition/presentation/exhibition_view_model.dart';
import 'package:collector_app/main.dart';

Json fixture() =>
    (jsonDecode(File('test/fixtures/curation.json').readAsStringSync())
            as Json)['data']
        as Json;

Curation layoutFixture() {
  final data = fixture();
  void removeNetworkMedia(dynamic value) {
    if (value is Map<String, dynamic>) {
      if (value.containsKey('media')) value['media'] = <dynamic>[];
      for (final child in value.values) {
        removeNetworkMedia(child);
      }
    } else if (value is List) {
      for (final child in value) {
        removeNetworkMedia(child);
      }
    }
  }

  removeNetworkMedia(data);
  return Curation.fromJson(data);
}

class FakeRepository implements ExhibitionRepository {
  FakeRepository(this.loader);
  final Future<Curation> Function() loader;
  @override
  Future<Curation> loadCuration() => loader();
}

void main() {
  test('API repository decodes the real seeded API contract', () async {
    final repo = ApiExhibitionRepository(
      ApiClient(
        MockClient((request) async {
          expect(request.url.path, '/api/v1/home/curation');
          expect(request.headers['Accept'], 'application/json');
          return http.Response(jsonEncode({'data': fixture()}), 200);
        }),
        Uri.parse('http://localhost/api/v1/'),
      ),
    );
    final data = await repo.loadCuration();
    expect(data.exhibitions.first.title.en, 'Beyond the horizon');
    expect(data.collections.length, 4);
    expect(
      data.exhibitions.first.hero!.media.first.url,
      contains('/storage/demo/'),
    );
  });
  test('API errors and malformed contracts have safe user messages', () async {
    for (final response in [
      http.Response('{}', 503),
      http.Response('not json', 200),
    ]) {
      final api = ApiClient(
        MockClient((_) async => response),
        Uri.parse('http://localhost/'),
      );
      await expectLater(api.get('home/curation'), throwsA(isA<ApiFailure>()));
    }
  });
  test(
    'view model retries failure and suppresses duplicate in-flight loads',
    () async {
      var calls = 0;
      final pending = Completer<Curation>();
      final vm = ExhibitionViewModel(
        FakeRepository(() {
          calls++;
          return pending.future;
        }),
      );
      final first = vm.load();
      await vm.load();
      expect(calls, 1);
      expect(vm.loading, isTrue);
      pending.complete(Curation.fromJson(fixture()));
      await first;
      expect(vm.curation, isNotNull);
      expect(vm.loading, isFalse);
      vm.dispose();
      var fail = true;
      final retry = ExhibitionViewModel(
        FakeRepository(() async {
          if (fail) throw const ApiFailure('Offline');
          return Curation.fromJson(fixture());
        }),
      );
      await retry.load();
      expect(retry.error, 'Offline');
      fail = false;
      await retry.load();
      expect(retry.error, isNull);
      expect(retry.curation, isNotNull);
      retry.dispose();
    },
  );
  test('disposing during load does not notify a disposed view model', () async {
    final pending = Completer<Curation>();
    final vm = ExhibitionViewModel(FakeRepository(() => pending.future));
    final loading = vm.load();
    vm.dispose();
    pending.complete(Curation.fromJson(fixture()));
    await loading;
  });
  for (final size in [
    const Size(1280, 800),
    const Size(800, 1280),
    const Size(390, 844),
  ]) {
    testWidgets(
      'entrance and home fit $size with text scaling and reduced motion',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: true);
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        // No external HTTP is needed for layout tests. Image failure is an explicit UI state.
        await tester.pumpWidget(
          CollectorApp(repository: FakeRepository(() async => layoutFixture())),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Beyond the horizon'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Enter Exhibition  →'));
        await tester.tap(find.text('Enter Exhibition  →'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('A different way to see.'), findsOneWidget);
        expect(find.text('Curator’s Selection'), findsOneWidget);
        expect(find.text('New Photographic Works'), findsOneWidget);
        expect(find.text('Featured Photographer'), findsOneWidget);
        expect(find.text('Limited Editions'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('failure offers a working retry without demo fallback', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      CollectorApp(
        repository: FakeRepository(() async {
          calls++;
          if (calls == 1) throw const ApiFailure('Offline');
          return layoutFixture();
        }),
      ),
    );
    await tester.pump();
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Beyond the horizon'), findsOneWidget);
    expect(calls, 2);
  });
}
