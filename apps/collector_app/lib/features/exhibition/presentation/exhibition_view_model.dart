import 'package:flutter/foundation.dart';

import '../../../core/api_client.dart';
import '../data/exhibition_repository.dart';
import '../data/models.dart';

class ExhibitionViewModel extends ChangeNotifier {
  ExhibitionViewModel(this.repository);
  final ExhibitionRepository repository;
  Curation? curation;
  String? error;
  bool loading = false;
  bool _disposed = false;
  Future<void> load() async {
    if (loading || _disposed) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      curation = await repository.loadCuration();
    } on ApiFailure catch (e) {
      error = e.message;
    } on Object {
      error = 'The exhibition could not be loaded. Please try again.';
    } finally {
      loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
