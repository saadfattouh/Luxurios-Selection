typedef Json = Map<String, dynamic>;

class LocalizedText {
  const LocalizedText(this.en, this.ar);
  factory LocalizedText.fromJson(Json json) =>
      LocalizedText(json['en'] as String, json['ar'] as String);
  final String en;
  final String ar;
  String forLanguage(String code) => code == 'ar' ? ar : en;
}

class ArtworkMedia {
  ArtworkMedia.fromJson(Json json)
    : url = json['url'] as String,
      alt = LocalizedText.fromJson(json['alt'] as Json),
      width = json['width'] as int,
      height = json['height'] as int;
  final String url;
  final LocalizedText alt;
  final int width;
  final int height;
}

class Photographer {
  Photographer.fromJson(Json json)
    : name = LocalizedText.fromJson(json['name'] as Json),
      bio = LocalizedText.fromJson(json['bio'] as Json);
  final LocalizedText name;
  final LocalizedText bio;
}

class Artwork {
  Artwork.fromJson(Json json)
    : id = json['id'] as String,
      title = LocalizedText.fromJson(json['title'] as Json),
      photographer = Photographer.fromJson(json['photographer'] as Json),
      media = (json['media'] as List)
          .map((e) => ArtworkMedia.fromJson(e as Json))
          .toList(),
      editionTotal = (json['editions'] as List).isEmpty
          ? null
          : (json['editions'][0]['total'] as int?);
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
      atmosphere = json['atmosphere'] as String;
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
