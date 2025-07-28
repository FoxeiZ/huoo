import 'package:equatable/equatable.dart';

class AlbumApiModel extends Equatable {
  final String id;
  final String title;
  final String? coverUri;
  final DateTime? releaseDate;
  final List<String> artistNames;
  final int songCount;
  final int totalDuration; // in seconds
  final String? createdAt;
  final String? updatedAt;

  const AlbumApiModel({
    required this.id,
    required this.title,
    this.coverUri,
    this.releaseDate,
    this.artistNames = const [],
    this.songCount = 0,
    this.totalDuration = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory AlbumApiModel.fromJson(Map<String, dynamic> json) {
    return AlbumApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUri: json['cover_uri'] as String?,
      releaseDate:
          json['release_date'] != null
              ? DateTime.parse(json['release_date'] as String)
              : null,
      artistNames:
          (json['artist_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      songCount: json['song_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_uri': coverUri,
      'release_date': releaseDate?.toIso8601String(),
      'artist_names': artistNames,
      'song_count': songCount,
      'total_duration': totalDuration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    coverUri,
    releaseDate,
    artistNames,
    songCount,
    totalDuration,
    createdAt,
    updatedAt,
  ];
}

class AlbumWithSongsApiModel extends AlbumApiModel {
  final List<Map<String, dynamic>> songs;

  const AlbumWithSongsApiModel({
    required super.id,
    required super.title,
    super.coverUri,
    super.releaseDate,
    super.artistNames = const [],
    super.songCount = 0,
    super.totalDuration = 0,
    super.createdAt,
    super.updatedAt,
    this.songs = const [],
  });

  factory AlbumWithSongsApiModel.fromJson(Map<String, dynamic> json) {
    return AlbumWithSongsApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUri: json['cover_uri'] as String?,
      releaseDate:
          json['release_date'] != null
              ? DateTime.parse(json['release_date'] as String)
              : null,
      artistNames:
          (json['artist_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      songCount: json['song_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      songs:
          (json['songs'] as List<dynamic>?)
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
    json['songs'] = songs;
    return json;
  }

  @override
  List<Object?> get props => [...super.props, songs];
}

class AlbumCreateRequest {
  final String title;
  final String? coverUri;
  final DateTime? releaseDate;
  final List<String> artistNames;

  const AlbumCreateRequest({
    required this.title,
    this.coverUri,
    this.releaseDate,
    this.artistNames = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'cover_uri': coverUri,
      'release_date': releaseDate?.toIso8601String(),
      'artist_names': artistNames,
    };
  }
}

class AlbumUpdateRequest {
  final String? title;
  final String? coverUri;
  final DateTime? releaseDate;
  final List<String>? artistNames;

  const AlbumUpdateRequest({
    this.title,
    this.coverUri,
    this.releaseDate,
    this.artistNames,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (coverUri != null) data['cover_uri'] = coverUri;
    if (releaseDate != null) {
      data['release_date'] = releaseDate!.toIso8601String();
    }
    if (artistNames != null) data['artist_names'] = artistNames;
    return data;
  }
}

class AlbumSearchFilters {
  final String? artist;
  final int? year;
  final String? genre;

  const AlbumSearchFilters({this.artist, this.year, this.genre});

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};
    if (artist != null) params['artist'] = artist!;
    if (year != null) params['year'] = year.toString();
    if (genre != null) params['genre'] = genre!;
    return params;
  }
}
