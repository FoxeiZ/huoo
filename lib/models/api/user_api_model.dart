import 'package:equatable/equatable.dart';

class UserApiModel extends Equatable {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool? emailVerified;

  const UserApiModel({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      emailVerified: json['email_verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'email_verified': emailVerified,
    };
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, emailVerified];
}

class UserUpdateRequest {
  final String? displayName;
  final String? photoUrl;

  const UserUpdateRequest({this.displayName, this.photoUrl});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    return data;
  }
}

class UserStatsApiModel extends Equatable {
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final int totalPlaylists;
  final int totalListeningTime; // in seconds
  final DateTime? lastActivity;

  const UserStatsApiModel({
    this.totalSongs = 0,
    this.totalArtists = 0,
    this.totalAlbums = 0,
    this.totalPlaylists = 0,
    this.totalListeningTime = 0,
    this.lastActivity,
  });

  factory UserStatsApiModel.fromJson(Map<String, dynamic> json) {
    return UserStatsApiModel(
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
