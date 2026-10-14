typedef Json = Map<String, dynamic>;

class LocalizedText {
  const LocalizedText(this.en, this.ar);
  factory LocalizedText.fromJson(Json json) =>
      LocalizedText(json['en'] as String? ?? '', json['ar'] as String? ?? '');
  final String en;
  final String ar;
  String forLanguage(String code) => code == 'ar' ? ar : en;
}

class ArtworkMedia {
  ArtworkMedia.fromJson(Json json)
    : url = json['url'] as String,
      alt = LocalizedText.fromJson(json['alt'] as Json),
      width = json['width'] as int,
      height = json['height'] as int,
      dominantColor = json['dominant_color'] as String?,
      renditions = (json['renditions'] as Json? ?? {}).map(
        (key, value) => MapEntry(key, ImageRendition.fromJson(value as Json)),
      );
  final Map<String, ImageRendition> renditions;
  final String? dominantColor;
  String urlFor(String kind) => renditions[kind]?.url ?? url;
  final String url;
  final LocalizedText alt;
  final int width;
  final int height;
}

class Photographer {
  Photographer.fromJson(Json json)
    : name = LocalizedText.fromJson(json['name'] as Json),
      bio = LocalizedText.fromJson(json['bio'] as Json? ?? {}),
      id = json['id'] as String? ?? '',
      slug = json['slug'] as String? ?? '';
  final String id;
  final String slug;
  final LocalizedText name;
  final LocalizedText bio;
}

class Artwork {
  Artwork.fromJson(Json json)
    : id = json['id'] as String,
      title = LocalizedText.fromJson(json['title'] as Json),
      photographer = Photographer.fromJson(
        json['photographer'] as Json? ??
            {
              'name': {'en': 'Photographer unavailable'},
            },
      ),
      media = (json['media'] as List? ?? [])
          .map((e) => ArtworkMedia.fromJson(e as Json))
          .toList(),
      editionTotal =
          json['edition_summary']?['total'] as int? ??
          ((json['editions'] as List? ?? []).isEmpty
              ? null
              : json['editions'][0]['total'] as int?),
      story = LocalizedText.fromJson(json['story'] as Json? ?? {}),
      editions = (json['editions'] as List? ?? [])
          .map((e) => ArtworkEdition.fromJson(e as Json))
          .toList(),
      availability = json['availability'] as String? ?? 'unknown',
      slug = json['slug'] as String? ?? '';
  final String slug;
  final LocalizedText story;
  final List<ArtworkEdition> editions;
  final String availability;
  final String id;
  final LocalizedText title;
  final Photographer photographer;
  final List<ArtworkMedia> media;
  final int? editionTotal;
}

class Exhibition {
  Exhibition.fromJson(Json json)
    : id = json['id'] as String,
      slug = json['slug'] as String,
      title = LocalizedText.fromJson(json['title'] as Json),
      subtitle = LocalizedText.fromJson(json['subtitle'] as Json),
      hero = json['hero_artwork'] == null
          ? null
          : Artwork.fromJson(json['hero_artwork'] as Json);
  final String id;
  final String slug;
  final LocalizedText title;
  final LocalizedText subtitle;
  final Artwork? hero;
}

class CollectionIdentity {
  CollectionIdentity.fromJson(Json json)
    : title = LocalizedText.fromJson(json['title'] as Json),
      atmosphere = json['atmosphere'] as String,
      slug = json['slug'] as String;
  final String slug;
  final LocalizedText title;
  final String atmosphere;
}

class Curation {
  Curation.fromJson(Json json)
    : exhibitions = (json['current_exhibitions'] as List)
          .map((e) => Exhibition.fromJson(e as Json))
          .toList(),
      curatorsSelection = (json['curators_selection'] as List)
          .map((e) => Artwork.fromJson(e as Json))
          .toList(),
      newWorks = (json['new_works'] as List)
          .map((e) => Artwork.fromJson(e as Json))
          .toList(),
      limitedEditions = (json['limited_editions'] as List)
          .map((e) => Artwork.fromJson(e as Json))
          .toList(),
      collections = (json['collections'] as List)
          .map((e) => CollectionIdentity.fromJson(e as Json))
          .toList(),
      featuredPhotographer = json['featured_photographer'] == null
          ? null
          : Photographer.fromJson(json['featured_photographer'] as Json);
  final List<Exhibition> exhibitions;
  final List<Artwork> curatorsSelection;
  final List<Artwork> newWorks;
  final List<Artwork> limitedEditions;
  final List<CollectionIdentity> collections;
  final Photographer? featuredPhotographer;
}

class ImageRendition {
  ImageRendition.fromJson(Json json)
    : url = json['url'] as String,
      width = json['width'] as int,
      height = json['height'] as int;
  final String url;
  final int width;
  final int height;
}

class ArtworkEdition {
  ArtworkEdition.fromJson(Json json)
    : label = LocalizedText.fromJson(json['label'] as Json? ?? {}),
      limited = json['is_limited'] as bool? ?? false,
      total = json['total'] as int?,
      availability = json['availability'] as String? ?? 'unknown',
      priceMinor = json['starting_price']?['amount_minor'] as int?,
      currency = json['starting_price']?['currency'] as String?,
      sizes = (json['sizes'] as List? ?? [])
          .map((e) => LocalizedText.fromJson(e['label'] as Json))
          .toList();
  final LocalizedText label;
  final bool limited;
  final int? total;
  final String availability;
  final int? priceMinor;
  final String? currency;
  final List<LocalizedText> sizes;
}

class ArtworkPage {
  ArtworkPage.fromJson(Json json)
    : items = (json['data'] as List)
          .map((e) => Artwork.fromJson(e as Json))
          .toList(),
      nextCursor = json['meta']?['next_cursor'] as String?;
  final List<Artwork> items;
  final String? nextCursor;
}
