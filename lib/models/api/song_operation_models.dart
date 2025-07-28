import 'package:equatable/equatable.dart';

/// Response model for song play recording (matches SongPlayResponse in Python)
class SongPlayResponse extends Equatable {
  final String message;
  final String songId;

  const SongPlayResponse({required this.message, required this.songId});

  factory SongPlayResponse.fromJson(Map<String, dynamic> json) {
    return SongPlayResponse(
      message: json['message']?.toString() ?? '',
      songId: json['song_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'song_id': songId};
  }

  @override
  List<Object?> get props => [message, songId];
}

/// Response model for favorite toggle (matches SongFavoriteResponse in Python)
class SongFavoriteResponse extends Equatable {
  final String message;
  final bool isFavorite;

  const SongFavoriteResponse({required this.message, required this.isFavorite});

  factory SongFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return SongFavoriteResponse(
      message: json['message']?.toString() ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'is_favorite': isFavorite};
  }

  @override
  List<Object?> get props => [message, isFavorite];
}

/// Response model for song lists (matches SongListResponse in Python)
class SongListResponse extends Equatable {
  final List<dynamic> songs; // Using dynamic for flexibility with SongResponse

  const SongListResponse({this.songs = const []});

  factory SongListResponse.fromJson(Map<String, dynamic> json) {
    return SongListResponse(songs: (json['songs'] as List<dynamic>?) ?? []);
  }

  Map<String, dynamic> toJson() {
    return {'songs': songs};
  }

  @override
  List<Object?> get props => [songs];
}

/// Response model for song deletion (matches SongDeleteResponse in Python)
class SongDeleteResponse extends Equatable {
  final String message;
  final String id;

  const SongDeleteResponse({required this.message, required this.id});

  factory SongDeleteResponse.fromJson(Map<String, dynamic> json) {
    return SongDeleteResponse(
      message: json['message']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'id': id};
  }

  @override
  List<Object?> get props => [message, id];
}
