import 'package:equatable/equatable.dart';

import 'package:huoo/models/api/song_response_model.dart';
import 'package:huoo/services/api_service.dart';

class ContinueListeningItem extends Equatable {
  final String id;
  final String title;
  final String type; // 'playlist', 'album', 'artist'
  final String color; // hex color code
  final String? imageUrl;
  final DateTime lastPlayed;
  final bool isNewRelease;
  final double progressPercentage; // 0-100

  const ContinueListeningItem({
    required this.id,
    required this.title,
    this.type = 'playlist',
    this.color = '#FFFFFF',
    this.imageUrl,
    required this.lastPlayed,
    this.isNewRelease = false,
    this.progressPercentage = 0.0,
  });

  factory ContinueListeningItem.fromJson(Map<String, dynamic> json) {
    return ContinueListeningItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String? ?? 'playlist',
      color: json['color'] as String? ?? '#FFFFFF',
      imageUrl:
          "${ApiConfig.baseUrl}/songs/cover/${json['image_url']?.toString().split('/').last ?? ''}",
      lastPlayed: DateTime.parse(json['last_played'] as String),
      isNewRelease: json['is_new_release'] as bool? ?? false,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'color': color,
      'image_url': imageUrl,
      'last_played': lastPlayed.toIso8601String(),
      'is_new_release': isNewRelease,
      'progress_percentage': progressPercentage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    color,
    imageUrl,
    lastPlayed,
    isNewRelease,
    progressPercentage,
  ];
}

class TopMixItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String color; // accent color hex code
  final String? imageUrl;
  final int songCount;
  final int totalDuration; // in seconds
  final List<SongResponse> songs;

  const TopMixItem({
    required this.id,
    required this.title,
    this.description,
    this.color = '#FFFFFF',
    this.imageUrl,
    this.songCount = 0,
    this.totalDuration = 0,
    this.songs = const [],
  });

  factory TopMixItem.fromJson(Map<String, dynamic> json) {
    return TopMixItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#FFFFFF',
      imageUrl:
          "${ApiConfig.baseUrl}/songs/cover/${json['image_url']?.toString().split('/').last ?? ''}",
      songCount: json['song_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (item) => SongResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'image_url': imageUrl,
      'song_count': songCount,
      'total_duration': totalDuration,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    color,
    imageUrl,
    songCount,
    totalDuration,
    songs,
  ];
}

class RecentListeningItem extends Equatable {
  final String id;
  final String title;
  final String? artist;
  final String type; // 'song', 'album', 'playlist'
  final String color; // hex color code
  final String? imageUrl;
  final DateTime lastPlayed;

  const RecentListeningItem({
    required this.id,
    required this.title,
    this.artist,
    this.type = 'song',
    this.color = '#FFFFFF',
    this.imageUrl,
    required this.lastPlayed,
  });

  factory RecentListeningItem.fromJson(Map<String, dynamic> json) {
    return RecentListeningItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      type: json['type'] as String? ?? 'song',
      color: json['color'] as String? ?? '#FFFFFF',
      imageUrl:
          "${ApiConfig.baseUrl}/songs/cover/${json['image_url']?.toString().split('/').last ?? ''}",
      lastPlayed: DateTime.parse(json['last_played'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'type': type,
      'color': color,
      'image_url': imageUrl,
      'last_played': lastPlayed.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    type,
    color,
    imageUrl,
    lastPlayed,
  ];
}

class UserStats extends Equatable {
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final int totalPlaylists;
  final int totalListeningTime; // in seconds
  final DateTime? lastActivity;

  const UserStats({
    this.totalSongs = 0,
    this.totalArtists = 0,
    this.totalAlbums = 0,
    this.totalPlaylists = 0,
    this.totalListeningTime = 0,
    this.lastActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalSongs: json['total_songs'] as int? ?? 0,
      totalArtists: json['total_artists'] as int? ?? 0,
      totalAlbums: json['total_albums'] as int? ?? 0,
      totalPlaylists: json['total_playlists'] as int? ?? 0,
      totalListeningTime: json['total_listening_time'] as int? ?? 0,
      lastActivity:
          json['last_activity'] != null
              ? DateTime.parse(json['last_activity'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_songs': totalSongs,
      'total_artists': totalArtists,
      'total_albums': totalAlbums,
      'total_playlists': totalPlaylists,
      'total_listening_time': totalListeningTime,
      'last_activity': lastActivity?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    totalSongs,
    totalArtists,
    totalAlbums,
    totalPlaylists,
    totalListeningTime,
    lastActivity,
  ];
}

class HomeScreenData extends Equatable {
  final UserStats userStats;
  final List<ContinueListeningItem> continueListening;
  final List<TopMixItem> topMixes;
  final List<RecentListeningItem> recentListening;
  final String greetingMessage;
  final String? userDisplayName;

  const HomeScreenData({
    required this.userStats,
    this.continueListening = const [],
    this.topMixes = const [],
    this.recentListening = const [],
    this.greetingMessage = '',
    this.userDisplayName,
  });

  factory HomeScreenData.fromJson(Map<String, dynamic> json) {
    return HomeScreenData(
      userStats: UserStats.fromJson(
        json['user_stats'] as Map<String, dynamic>? ?? {},
      ),
      continueListening:
          (json['continue_listening'] as List<dynamic>?)
              ?.map(
                (item) => ContinueListeningItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      topMixes:
          (json['top_mixes'] as List<dynamic>?)
              ?.map((item) => TopMixItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      recentListening:
          (json['recent_listening'] as List<dynamic>?)
              ?.map(
                (item) =>
                    RecentListeningItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      greetingMessage: json['greeting_message'] as String? ?? '',
      userDisplayName: json['user_display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_stats': userStats.toJson(),
      'continue_listening':
          continueListening.map((item) => item.toJson()).toList(),
      'top_mixes': topMixes.map((item) => item.toJson()).toList(),
      'recent_listening': recentListening.map((item) => item.toJson()).toList(),
      'greeting_message': greetingMessage,
      'user_display_name': userDisplayName,
    };
  }

  @override
  List<Object?> get props => [
    userStats,
    continueListening,
    topMixes,
    recentListening,
    greetingMessage,
    userDisplayName,
  ];
}

class ContinueListeningResponse extends Equatable {
  final List<ContinueListeningItem> items;
  final int totalCount;

  const ContinueListeningResponse({this.items = const [], this.totalCount = 0});

  factory ContinueListeningResponse.fromJson(Map<String, dynamic> json) {
    return ContinueListeningResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => ContinueListeningItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}

class TopMixesResponse extends Equatable {
  final List<TopMixItem> items;
  final int totalCount;

  const TopMixesResponse({this.items = const [], this.totalCount = 0});

  factory TopMixesResponse.fromJson(Map<String, dynamic> json) {
    return TopMixesResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => TopMixItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}

class RecentListeningResponse extends Equatable {
  final List<RecentListeningItem> items;
  final int totalCount;

  const RecentListeningResponse({this.items = const [], this.totalCount = 0});

  factory RecentListeningResponse.fromJson(Map<String, dynamic> json) {
    return RecentListeningResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    RecentListeningItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  @override
  List<Object?> get props => [items, totalCount];
}
