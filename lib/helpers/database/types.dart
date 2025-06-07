import 'package:huoo/models/song.dart';

class BulkImportResult {
  List<Song> successfulSongs = [];
  List<BulkImportError> failedSongs = [];

  int get totalProcessed => successfulSongs.length + failedSongs.length;
  int get successCount => successfulSongs.length;
  int get failureCount => failedSongs.length;
  double get successRate =>
      totalProcessed > 0 ? successCount / totalProcessed : 0.0;
}

class BulkImportError {
  final Map<String, dynamic> songData;
  final String error;

  BulkImportError({required this.songData, required this.error});

  String get songTitle => (songData['song'] as Song?)?.title ?? 'Unknown Song';
}

class DatabaseStatistics {
  final int totalSongs;
  final int totalAlbums;
  final int totalArtists;
  final int totalDurationMs;
  final List<GenreStatistic> topGenres;
  final int recentlyAddedCount;

  DatabaseStatistics({
    required this.totalSongs,
    required this.totalAlbums,
    required this.totalArtists,
    required this.totalDurationMs,
    required this.topGenres,
    required this.recentlyAddedCount,
  });

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class GenreStatistic {
  final String genre;
  final int count;

  GenreStatistic({required this.genre, required this.count});
}

class CleanupResult {
  final int deletedAlbums;
  final int deletedArtists;

  CleanupResult({required this.deletedAlbums, required this.deletedArtists});

  int get totalDeleted => deletedAlbums + deletedArtists;
}
