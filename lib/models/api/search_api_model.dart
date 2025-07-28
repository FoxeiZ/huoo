import 'package:equatable/equatable.dart';
import 'package:huoo/models/api/song_response_model.dart';
import 'package:huoo/services/api_service.dart';

class SongSearchResult extends Equatable {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final int? duration;
  final String path;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? cover;
  final List<String> genres;

  const SongSearchResult({
    required this.id,
    required this.title,
    required this.path,
    this.artist,
    this.album,
    this.duration,
    this.genre,
    this.year,
    this.trackNumber,
    this.createdAt,
    this.updatedAt,
    this.cover,
    this.genres = const [],
  });

  factory SongSearchResult.fromJson(Map<String, dynamic> json) {
    return SongSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Title',
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      duration: json['duration'] as int?,
      path: "${ApiConfig.baseUrl}/songs/file/${json['id']?.toString() ?? ''}",
      genre: json['genre'] as String?,
      year: json['year'] as int?,
      trackNumber: json['track_number'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      cover:
          json['cover'] != null
              ? "${ApiConfig.baseUrl}/songs/cover/${json['cover']?.toString().split('/').last ?? ''}"
              : null,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'path': path,
      'genre': genre,
      'year': year,
      'track_number': trackNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'cover': cover,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    album,
    duration,
    path,
    genre,
    year,
    trackNumber,
    createdAt,
    updatedAt,
    cover,
  ];
}

class ArtistSearchResult extends Equatable {
  final String id;
  final String name;
  final int songCount;
  final int albumCount;
  final List<String> genres;
  final DateTime? firstSeen;
  final List<SongResponse> songs;
  final String? cover;

  const ArtistSearchResult({
    required this.id,
    required this.name,
    this.songCount = 0,
    this.albumCount = 0,
    this.genres = const [],
    this.firstSeen,
    this.songs = const [],
    this.cover,
  });

  factory ArtistSearchResult.fromJson(Map<String, dynamic> json) {
    return ArtistSearchResult(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Artist',
      songCount: json['song_count'] as int? ?? 0,
      albumCount: json['album_count'] as int? ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      firstSeen:
          json['first_seen'] != null
              ? DateTime.parse(json['first_seen'] as String)
              : null,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((e) => SongResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cover:
          json['cover'] != null
              ? "${ApiConfig.baseUrl}/artists/cover/${json['cover']?.toString().split('/').last ?? ''}"
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'song_count': songCount,
      'album_count': albumCount,
      'genres': genres,
      'first_seen': firstSeen?.toIso8601String(),
      'songs': songs.map((song) => song.toJson()).toList(),
      'cover': cover,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    songCount,
    albumCount,
    genres,
    firstSeen,
    songs,
    cover,
  ];
}

class AlbumSearchResult extends Equatable {
  final String id;
  final String title;
  final String? artist;
  final int? year;
  final int songCount;
  final int? totalDuration;
  final List<String> genres;
  final String? cover;
  final List<SongResponse> songs;

  const AlbumSearchResult({
    required this.id,
    required this.title,
    this.artist,
    this.year,
    this.songCount = 0,
    this.totalDuration,
    this.genres = const [],
    this.cover,
    this.songs = const [],
  });

  factory AlbumSearchResult.fromJson(Map<String, dynamic> json) {
    return AlbumSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Album',
      artist: json['artist'] as String?,
      year: json['year'] as int?,
      songCount: json['song_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      cover: json['cover'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'song_count': songCount,
      'total_duration': totalDuration,
      'genres': genres,
      'cover': cover,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    year,
    songCount,
    totalDuration,
    genres,
    cover,
    songs,
  ];
}

class SearchResponse extends Equatable {
  final String query;
  final int totalResults;
  final int page;
  final int limit;
  final String? searchType;
  final List<SongSearchResult> songs;
  final List<ArtistSearchResult> artists;
  final List<AlbumSearchResult> albums;
  final double executionTimeMs;

  const SearchResponse({
    required this.query,
    this.totalResults = 0,
    this.page = 1,
    this.limit = 20,
    this.searchType,
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.executionTimeMs = 0.0,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      query: json['query']?.toString() ?? '',
      totalResults: json['total_results'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      searchType: json['search_type'] as String?,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (songJson) =>
                    SongSearchResult.fromJson(songJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      artists:
          (json['artists'] as List<dynamic>?)
              ?.map(
                (artistJson) => ArtistSearchResult.fromJson(
                  artistJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      albums:
          (json['albums'] as List<dynamic>?)
              ?.map(
                (albumJson) => AlbumSearchResult.fromJson(
                  albumJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      executionTimeMs: (json['execution_time_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'total_results': totalResults,
      'page': page,
      'limit': limit,
      'search_type': searchType,
      'songs': songs.map((song) => song.toJson()).toList(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'albums': albums.map((album) => album.toJson()).toList(),
      'execution_time_ms': executionTimeMs,
    };
  }

  @override
  List<Object?> get props => [
    query,
    totalResults,
    page,
    limit,
    searchType,
    songs,
    artists,
    albums,
    executionTimeMs,
  ];
}

class SearchSuggestion extends Equatable {
  final String text;
  final bool isExactMatch;
  final String type;
  final int count;

  const SearchSuggestion({
    required this.text,
    this.isExactMatch = false,
    this.type = 'song',
    this.count = 0,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      text: json['text'] as String,
      isExactMatch: json['is_exact_match'] as bool? ?? false,
      type: json['type'] as String? ?? 'song',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_exact_match': isExactMatch,
      'type': type,
      'count': count,
    };
  }

  @override
  List<Object?> get props => [text, isExactMatch, type, count];
}

class SearchSuggestionsResponse extends Equatable {
  final String query;
  final List<SearchSuggestion> suggestions;

  const SearchSuggestionsResponse({
    required this.query,
    this.suggestions = const [],
  });

  factory SearchSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionsResponse(
      query: json['query'] as String,
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map(
                (suggestionJson) => SearchSuggestion.fromJson(
                  suggestionJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'suggestions':
          suggestions.map((suggestion) => suggestion.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [query, suggestions];
}
