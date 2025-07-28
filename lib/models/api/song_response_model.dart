import 'package:equatable/equatable.dart';

import 'package:huoo/services/api_service.dart';

class SongResponse extends Equatable {
  final String id;
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
  final int playCount;
  final int likes;
  final String? createdAt;
  final String? updatedAt;

  const SongResponse({
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

  factory SongResponse.fromJson(Map<String, dynamic> json) {
    return SongResponse(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Title',
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
