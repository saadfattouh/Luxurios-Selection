import 'package:flutter/foundation.dart';

// Phase 5 may replace this with a guest-session API repository without changing views.
abstract class ShortlistRepository extends ChangeNotifier {
  bool contains(String artworkId);
  Future<void> setSaved(String artworkId, bool saved);
}

class MemoryShortlistRepository extends ShortlistRepository {
  final Set<String> _ids = {};
  @override
  bool contains(String artworkId) => _ids.contains(artworkId);
  @override
  Future<void> setSaved(String artworkId, bool saved) async {
    saved ? _ids.add(artworkId) : _ids.remove(artworkId);
    notifyListeners();
  }
}
