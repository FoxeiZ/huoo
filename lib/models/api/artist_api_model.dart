import 'package:equatable/equatable.dart';

class ArtistApiModel extends Equatable {
  final String id;
  final String name;
  final String? imageUri;
  final String? bio;
  final int songCount;
  final int albumCount;
  final int totalDuration; // in seconds
  final List<String> genres;
  final String? createdAt;
  final String? updatedAt;

  const ArtistApiModel({
    required this.id,
    required this.name,
    this.imageUri,
    this.bio,
    this.songCount = 0,
    this.albumCount = 0,
    this.totalDuration = 0,
    this.genres = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ArtistApiModel.fromJson(Map<String, dynamic> json) {
    return ArtistApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUri: json['image_uri'] as String?,
      bio: json['bio'] as String?,
      songCount: json['song_count'] as int? ?? 0,
      albumCount: json['album_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_uri': imageUri,
      'bio': bio,
      'song_count': songCount,
      'album_count': albumCount,
      'total_duration': totalDuration,
      'genres': genres,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUri,
    bio,
    songCount,
    albumCount,
    totalDuration,
    genres,
    createdAt,
    updatedAt,
  ];
}

class ArtistWithDetailsApiModel extends ArtistApiModel {
  final List<Map<String, dynamic>> albums;
  final List<Map<String, dynamic>> topSongs;

  const ArtistWithDetailsApiModel({
    required super.id,
    required super.name,
    super.imageUri,
    super.bio,
    super.songCount = 0,
    super.albumCount = 0,
    super.totalDuration = 0,
    super.genres = const [],
    super.createdAt,
    super.updatedAt,
    this.albums = const [],
    this.topSongs = const [],
  });

  factory ArtistWithDetailsApiModel.fromJson(Map<String, dynamic> json) {
    return ArtistWithDetailsApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUri: json['image_uri'] as String?,
      bio: json['bio'] as String?,
      songCount: json['song_count'] as int? ?? 0,
      albumCount: json['album_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      albums:
          (json['albums'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      topSongs:
          (json['top_songs'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['albums'] = albums;
    json['top_songs'] = topSongs;
    return json;
  }

  @override
  List<Object?> get props => [...super.props, albums, topSongs];
}

class ArtistCreateRequest {
  final String name;
  final String? imageUri;
  final String? bio;

  const ArtistCreateRequest({required this.name, this.imageUri, this.bio});

  Map<String, dynamic> toJson() {
    return {'name': name, 'image_uri': imageUri, 'bio': bio};
  }
}

class ArtistUpdateRequest {
  final String? name;
  final String? imageUri;
  final String? bio;

  const ArtistUpdateRequest({this.name, this.imageUri, this.bio});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (imageUri != null) data['image_uri'] = imageUri;
    if (bio != null) data['bio'] = bio;
    return data;
  }
}

class ArtistSearchFilters {
  final String? genre;
  final bool? hasAlbums;

  const ArtistSearchFilters({this.genre, this.hasAlbums});

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};
    if (genre != null) params['genre'] = genre!;
    if (hasAlbums != null) params['has_albums'] = hasAlbums.toString();
    return params;
  }
}
