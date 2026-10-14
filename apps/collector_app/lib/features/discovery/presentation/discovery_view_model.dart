import 'package:flutter/foundation.dart';
import '../../../core/api_client.dart';
import '../../exhibition/data/models.dart';
import '../data/discovery_repository.dart';

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryViewModel(this.repository, this.kind, this.slug);
  final DiscoveryRepository repository;
  final String kind;
  final String slug;
  final List<Artwork> items = [];
  Map<String, String> filters = {};
  String title = '';
  String atmosphere = 'atmospheric';
  String? error;
  String? nextCursor;
  bool loading = false;
  bool initialized = false;
  int index = 0;
  int _generation = 0;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load({bool reset = false}) async {
    if (loading && !reset) return;
    if (initialized && nextCursor == null && !reset) return;
    final generation = ++_generation;
    if (reset) {
      items.clear();
      index = 0;
      nextCursor = null;
      initialized = false;
    }
    loading = true;
    error = null;
    _notify();
    try {
      if (!initialized) {
        if (kind == 'collections') {
          final identity = await repository.collection(slug);
          if (_disposed || generation != _generation) return;
          title = identity.title.en;
          atmosphere = identity.atmosphere;
        } else {
          final identity = await repository.exhibition(slug);
          if (_disposed || generation != _generation) return;
          title = identity.title.en;
        }
      }
      final page = await repository.artworks(
        kind,
        slug,
        cursor: nextCursor,
        filters: Map.of(filters),
      );
      if (_disposed || generation != _generation) return;
      final ids = items.map((a) => a.id).toSet();
      items.addAll(page.items.where((a) => ids.add(a.id)));
      nextCursor = page.nextCursor;
      initialized = true;
    } on ApiFailure catch (e) {
      if (generation == _generation) error = e.message;
    } on Object {
      if (generation == _generation)
        error = 'The exhibition is temporarily unavailable.';
    } finally {
      if (generation == _generation && !_disposed) {
        loading = false;
        _notify();
      }
    }
  }

  Future<void> filter(Map<String, String> value) {
    filters = Map.of(value);
    return load(reset: true);
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
