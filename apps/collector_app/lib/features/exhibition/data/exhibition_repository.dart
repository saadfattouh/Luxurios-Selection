import '../../../core/api_client.dart';
import 'models.dart';

abstract interface class ExhibitionRepository {
  Future<Curation> loadCuration();
}

class ApiExhibitionRepository implements ExhibitionRepository {
  ApiExhibitionRepository(this.api);
  final ApiClient api;
  @override
  Future<Curation> loadCuration() async {
    try {
      return Curation.fromJson(
        (await api.get('home/curation'))['data'] as Json,
      );
    } on ApiFailure {
      rethrow;
    } on Object {
      throw const ApiFailure(
        'The exhibition data could not be read. Please try again.',
      );
    }
  }
}
