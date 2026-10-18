import '../../../core/api_client.dart';
import '../../exhibition/data/models.dart';

abstract interface class DiscoveryRepository {
  Future<CollectionIdentity> collection(String slug);
  Future<Exhibition> exhibition(String slug);
  Future<ArtworkPage> artworks(
    String kind,
    String slug, {
    String? cursor,
    Map<String, String> filters = const {},
  });
  Future<Artwork> artwork(String id);
  Future<Photographer> photographer(String id);
}

class ApiDiscoveryRepository implements DiscoveryRepository {
  ApiDiscoveryRepository(this.api);
  final ApiClient api;
  Future<T> _decode<T>(String path, T Function(Json) decode) async {
    try {
      return decode(await api.get(path));
    } on ApiFailure {
      rethrow;
    } on Object {
      throw const ApiFailure(
        'This part of the exhibition could not be read. Please try again.',
      );
    }
  }

  @override
  Future<CollectionIdentity> collection(String slug) => _decode(
    'collections/${Uri.encodeComponent(slug)}',
    (j) => CollectionIdentity.fromJson(j['data'] as Json),
  );
  @override
  Future<Exhibition> exhibition(String slug) => _decode(
    'exhibitions/${Uri.encodeComponent(slug)}',
    (j) => Exhibition.fromJson(j['data'] as Json),
  );
  @override
  Future<ArtworkPage> artworks(
    String kind,
    String slug, {
    String? cursor,
    Map<String, String> filters = const {},
  }) {
    if (kind != 'collections' && kind != 'exhibitions')
      throw ArgumentError.value(kind);
    final path = Uri(
      path: '$kind/$slug/artworks',
      queryParameters: {
        'per_page': '12',
        ...filters,
        if (cursor != null) 'cursor': cursor,
      },
    ).toString();
    return _decode(path, ArtworkPage.fromJson);
  }

  @override
  Future<Artwork> artwork(String id) => _decode(
    'artworks/${Uri.encodeComponent(id)}',
    (j) => Artwork.fromJson(j['data'] as Json),
  );
  @override
  Future<Photographer> photographer(String id) => _decode(
    'photographers/${Uri.encodeComponent(id)}',
    (j) => Photographer.fromJson(j['data'] as Json),
  );
}
