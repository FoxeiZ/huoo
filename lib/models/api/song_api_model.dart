import 'package:equatable/equatable.dart';

import 'package:huoo/services/api_service.dart';

class SongApiModel extends Equatable {
  final String id;
  final String title;
  final List<String> artistNames;
  final String? albumId;
  final String? albumTitle;
  final int? year;
  final int trackNumber;
  final int trackTotal;
  final int? duration; // in seconds
  final List<String> genres;
  final int discNumber;
  final int totalDisc;
  final String? lyrics;
  final double? rating;
  final String path;
  final String? cover;
  final int playCount;
  final int likes;
  final String? createdAt;
  final String? updatedAt;

  const SongApiModel({
    required this.id,
    required this.title,
    this.artistNames = const [],
    this.albumId,
    this.albumTitle,
    this.year,
    this.trackNumber = 0,
    this.trackTotal = 0,
    this.duration,
    this.genres = const [],
    this.discNumber = 0,
    this.totalDisc = 0,
    this.lyrics,
    this.rating,
    required this.path,
    this.cover,
    this.playCount = 0,
    this.likes = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SongApiModel.fromJson(Map<String, dynamic> json) {
    return SongApiModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Unknown Title',
      artistNames:
          (json['artist_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      albumId: json['album_id'] as String?,
      albumTitle: json['album_title'] as String?,
      year: json['year'] as int?,
      trackNumber: json['track_number'] as int? ?? 0,
      trackTotal: json['track_total'] as int? ?? 0,
      duration: json['duration'] as int?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      discNumber: json['disc_number'] as int? ?? 0,
      totalDisc: json['total_disc'] as int? ?? 0,
      lyrics: json['lyrics'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      path: "${ApiConfig.baseUrl}/songs/file/${json['id']?.toString() ?? ''}",
      cover:
          "${ApiConfig.baseUrl}/songs/cover/${json['cover']?.toString().split('/').last ?? ''}",
      playCount: json['play_count'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_names': artistNames,
      'album_id': albumId,
      'album_title': albumTitle,
      'year': year,
      'track_number': trackNumber,
      'track_total': trackTotal,
      'duration': duration,
      'genres': genres,
      'disc_number': discNumber,
      'total_disc': totalDisc,
      'lyrics': lyrics,
      'rating': rating,
      'path': path,
      'cover': cover,
      'play_count': playCount,
      'likes': likes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artistNames,
    albumId,
    albumTitle,
    year,
    trackNumber,
    trackTotal,
    duration,
    genres,
    discNumber,
    totalDisc,
    lyrics,
    rating,
    path,
    cover,
    playCount,
    likes,
    createdAt,
    updatedAt,
  ];
}

class SongCreateRequest {
  final String title;
  final List<String> artistNames;
  final String? albumId;
  final String? albumTitle;
  final int? year;
  final int trackNumber;
  final int trackTotal;
  final int? duration;
  final List<String> genres;
  final int discNumber;
  final int totalDisc;
  final String? lyrics;
  final double? rating;
  final String path;
  final String? cover;

  const SongCreateRequest({
    required this.title,
    this.artistNames = const [],
    this.albumId,
    this.albumTitle,
    this.year,
    this.trackNumber = 0,
    this.trackTotal = 0,
    this.duration,
    this.genres = const [],
    this.discNumber = 0,
    this.totalDisc = 0,
    this.lyrics,
    this.rating,
    required this.path,
    this.cover,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist_names': artistNames,
      'album_id': albumId,
      'album_title': albumTitle,
      'year': year,
      'track_number': trackNumber,
      'track_total': trackTotal,
      'duration': duration,
      'genres': genres,
      'disc_number': discNumber,
      'total_disc': totalDisc,
      'lyrics': lyrics,
      'rating': rating,
      'path': path,
      'cover': cover,
    };
  }
}

class SongUpdateRequest {
  final String? title;
  final List<String>? artistNames;
  final String? albumId;
  final String? albumTitle;
  final int? year;
  final int? trackNumber;
  final int? trackTotal;
  final int? duration;
  final List<String>? genres;
  final int? discNumber;
  final int? totalDisc;
  final String? lyrics;
  final double? rating;
  final String? path;
  final String? cover;

  const SongUpdateRequest({
    this.title,
    this.artistNames,
    this.albumId,
    this.albumTitle,
    this.year,
    this.trackNumber,
    this.trackTotal,
    this.duration,
    this.genres,
    this.discNumber,
    this.totalDisc,
    this.lyrics,
    this.rating,
    this.path,
    this.cover,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (artistNames != null) data['artist_names'] = artistNames;
    if (albumId != null) data['album_id'] = albumId;
    if (albumTitle != null) data['album_title'] = albumTitle;
    if (year != null) data['year'] = year;
    if (trackNumber != null) data['track_number'] = trackNumber;
    if (trackTotal != null) data['track_total'] = trackTotal;
    if (duration != null) data['duration'] = duration;
    if (genres != null) data['genres'] = genres;
    if (discNumber != null) data['disc_number'] = discNumber;
    if (totalDisc != null) data['total_disc'] = totalDisc;
    if (lyrics != null) data['lyrics'] = lyrics;
    if (rating != null) data['rating'] = rating;
    if (path != null) data['path'] = path;
    if (cover != null) data['cover'] = cover;
    return data;
  }
}

class SongSearchFilters {
  final String? genre;
  final String? artist;
  final int? year;
  final String? albumId;
  final String? albumTitle;

  const SongSearchFilters({
    this.genre,
    this.artist,
    this.year,
    this.albumId,
    this.albumTitle,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};
    if (genre != null) params['genre'] = genre!;
    if (artist != null) params['artist'] = artist!;
    if (year != null) params['year'] = year.toString();
    if (albumId != null) params['album_id'] = albumId!;
    if (albumTitle != null) params['album_title'] = albumTitle!;
    return params;
  }
}
