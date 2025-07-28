import 'package:equatable/equatable.dart';

// ============== SONG REQUEST MODELS ==============
class SongCreateRequest extends Equatable {
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

  @override
  List<Object?> get props => [
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
  ];
}

class SongUpdateRequest extends Equatable {
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
    final data = <String, dynamic>{};
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

  @override
  List<Object?> get props => [
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
  ];
}

// ============== ALBUM REQUEST MODELS ==============
class AlbumCreateRequest extends Equatable {
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

  @override
  List<Object?> get props => [title, coverUri, releaseDate, artistNames];
}

class AlbumUpdateRequest extends Equatable {
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
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (coverUri != null) data['cover_uri'] = coverUri;
    if (releaseDate != null) {
      data['release_date'] = releaseDate!.toIso8601String();
    }
    if (artistNames != null) data['artist_names'] = artistNames;
    return data;
  }

  @override
  List<Object?> get props => [title, coverUri, releaseDate, artistNames];
}

// ============== ARTIST REQUEST MODELS ==============
class ArtistCreateRequest extends Equatable {
  final String name;
  final String? imageUri;
  final String? bio;

  const ArtistCreateRequest({required this.name, this.imageUri, this.bio});

  Map<String, dynamic> toJson() {
    return {'name': name, 'image_uri': imageUri, 'bio': bio};
  }

  @override
  List<Object?> get props => [name, imageUri, bio];
}

class ArtistUpdateRequest extends Equatable {
  final String? name;
  final String? imageUri;
  final String? bio;

  const ArtistUpdateRequest({this.name, this.imageUri, this.bio});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (imageUri != null) data['image_uri'] = imageUri;
    if (bio != null) data['bio'] = bio;
    return data;
  }

  @override
  List<Object?> get props => [name, imageUri, bio];
}

// ============== PLAYLIST REQUEST MODELS ==============
class AddSongToPlaylistRequest extends Equatable {
  final String songId;

  const AddSongToPlaylistRequest({required this.songId});

  Map<String, dynamic> toJson() {
    return {'song_id': songId};
  }

  @override
  List<Object?> get props => [songId];
}
