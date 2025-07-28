import 'package:equatable/equatable.dart';

class PlaylistApiModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int songCount;
  final String duration;
  final String createdAt;
  final String updatedAt;
  final List<SongInPlaylist> songs;

  const PlaylistApiModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.isPublic = false,
    this.songCount = 0,
    this.duration = '0m',
    required this.createdAt,
    required this.updatedAt,
    this.songs = const [],
  });

  factory PlaylistApiModel.fromJson(Map<String, dynamic> json) {
    return PlaylistApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      songCount: json['song_count'] as int? ?? 0,
      duration: json['duration'] as String? ?? '0m',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (songJson) =>
                    SongInPlaylist.fromJson(songJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_url': coverUrl,
      'is_public': isPublic,
      'song_count': songCount,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    coverUrl,
    isPublic,
    songCount,
    duration,
    createdAt,
    updatedAt,
    songs,
  ];
}

class SongInPlaylist extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String? coverUrl;

  const SongInPlaylist({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.coverUrl,
  });

  factory SongInPlaylist.fromJson(Map<String, dynamic> json) {
    return SongInPlaylist(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      duration: json['duration'] as String,
      coverUrl: json['cover_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'cover_url': coverUrl,
    };
  }

  @override
  List<Object?> get props => [id, title, artist, duration, coverUrl];
}

class PlaylistCreateRequest {
  final String name;
  final String? description;
  final String? coverUrl;
  final bool? isPublic;

  const PlaylistCreateRequest({
    required this.name,
    this.description,
    this.coverUrl,
    this.isPublic,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};
    if (description != null) data['description'] = description;
    if (coverUrl != null) data['cover_url'] = coverUrl;
    if (isPublic != null) data['is_public'] = isPublic;
    return data;
  }
}

class AddSongToPlaylistRequest {
  final String songId;

  const AddSongToPlaylistRequest({required this.songId});

  Map<String, dynamic> toJson() {
    return {'song_id': songId};
  }
}

class PlaylistListResponse extends Equatable {
  final List<PlaylistApiModel> playlists;
  final int total;
  final int limit;
  final int offset;

  const PlaylistListResponse({
    required this.playlists,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PlaylistListResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistListResponse(
      playlists:
          (json['playlists'] as List<dynamic>)
              .map(
                (playlistJson) => PlaylistApiModel.fromJson(
                  playlistJson as Map<String, dynamic>,
                ),
              )
              .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }

  @override
  List<Object?> get props => [playlists, total, limit, offset];
}

class PlaylistListAPIResponse extends Equatable {
  final String status;
  final PlaylistListResponse data;

  const PlaylistListAPIResponse({this.status = 'success', required this.data});

  factory PlaylistListAPIResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistListAPIResponse(
      status: json['status']?.toString() ?? 'success',
      data: PlaylistListResponse.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }

  @override
  List<Object?> get props => [status, data];
}
