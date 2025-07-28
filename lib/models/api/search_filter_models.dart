import 'package:equatable/equatable.dart';

class SongSearchFilters extends Equatable {
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
    final params = <String, String>{};
    if (genre != null) params['genre'] = genre!;
    if (artist != null) params['artist'] = artist!;
    if (year != null) params['year'] = year.toString();
    if (albumId != null) params['album_id'] = albumId!;
    if (albumTitle != null) params['album_title'] = albumTitle!;
    return params;
  }

  Map<String, dynamic> toJson() {
    return {
      'genre': genre,
      'artist': artist,
      'year': year,
      'album_id': albumId,
      'album_title': albumTitle,
    };
  }

  @override
  List<Object?> get props => [genre, artist, year, albumId, albumTitle];
}

class AlbumSearchFilters extends Equatable {
  final String? artist;
  final int? year;
  final String? genre;

  const AlbumSearchFilters({this.artist, this.year, this.genre});

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (artist != null) params['artist'] = artist!;
    if (year != null) params['year'] = year.toString();
    if (genre != null) params['genre'] = genre!;
    return params;
  }

  Map<String, dynamic> toJson() {
    return {'artist': artist, 'year': year, 'genre': genre};
  }

  @override
  List<Object?> get props => [artist, year, genre];
}

class ArtistSearchFilters extends Equatable {
  final String? genre;
  final bool? hasAlbums;

  const ArtistSearchFilters({this.genre, this.hasAlbums});

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (genre != null) params['genre'] = genre!;
    if (hasAlbums != null) params['has_albums'] = hasAlbums.toString();
    return params;
  }

  Map<String, dynamic> toJson() {
    return {'genre': genre, 'has_albums': hasAlbums};
  }

  @override
  List<Object?> get props => [genre, hasAlbums];
}
