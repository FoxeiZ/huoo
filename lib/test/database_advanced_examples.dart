// Advanced examples for testing the enhanced database features
// This file demonstrates performance optimization, bulk imports, and database maintenance
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';

class DatabaseAdvancedExamples {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Example 1: Bulk import with progress tracking
  Future<void> demonstrateBulkImport() async {
    // Simulate a large music library import
    final List<Map<String, dynamic>> musicLibrary = [];

    // Create 1000 sample songs across multiple albums and artists
    for (int i = 0; i < 1000; i++) {
      final albumIndex = i ~/ 10; // 10 songs per album
      final artistIndex = i ~/ 50; // Multiple albums per artist

      musicLibrary.add({
        'song': Song(
          path: '/music/library/song_$i.mp3',
          source: AudioSourceEnum.local,
          title: 'Song $i',
          trackNumber: (i % 10) + 1,
          trackTotal: 10,
          duration: Duration(minutes: 3, seconds: 30 + (i % 60)),
          performers: ['Artist $artistIndex'],
          genres: _getRandomGenres(i),
          discNumber: 1,
          totalDisc: 1,
          year: 2020 + (i % 4),
        ),
        'album': Album(
          title: 'Album $albumIndex',
          coverUri: 'https://example.com/covers/album_$albumIndex.jpg',
          releaseDate: DateTime(2020 + (albumIndex % 4)),
        ),
        'artists': [
          Artist(
            name: 'Artist $artistIndex',
            imageUri: 'https://example.com/artists/artist_$artistIndex.jpg',
            bio: 'Biography for Artist $artistIndex',
          ),
        ],
      });
    }

    print('Starting bulk import of ${musicLibrary.length} songs...');

    // Track progress
    final stopwatch = Stopwatch()..start();

    final result = await _dbHelper.bulkImportSongs(
      songDataList: musicLibrary,
      chunkSize: 100, // Process 100 songs at a time
      onProgress: (processed, total) {
        final percentage = (processed / total * 100).toStringAsFixed(1);
        print('Progress: $processed/$total ($percentage%)');
      },
    );

    stopwatch.stop();

    print('\n=== Bulk Import Results ===');
    print('Total processed: ${result.totalProcessed}');
    print('Successful: ${result.successCount}');
    print('Failed: ${result.failureCount}');
    print('Success rate: ${(result.successRate * 100).toStringAsFixed(1)}%');
    print('Time taken: ${stopwatch.elapsed.inSeconds} seconds');

    if (result.failedSongs.isNotEmpty) {
      print('\nFailed songs:');
      for (final failure in result.failedSongs.take(5)) {
        print('- ${failure.songTitle}: ${failure.error}');
      }
    }
  }

  /// Example 2: Database statistics and analytics
  Future<void> demonstrateStatistics() async {
    print('\n=== Database Statistics ===');

    final stats = await _dbHelper.getDatabaseStatistics();

    print('Total Songs: ${stats.totalSongs}');
    print('Total Albums: ${stats.totalAlbums}');
    print('Total Artists: ${stats.totalArtists}');
    print('Total Duration: ${stats.formattedDuration}');
    print('Recently Added (last 7 days): ${stats.recentlyAddedCount}');

    print('\nTop Genres:');
    for (final genre in stats.topGenres) {
      print('- ${genre.genre}: ${genre.count} songs');
    }
  }

  /// Example 3: Database maintenance and cleanup
  Future<void> demonstrateCleanup() async {
    print('\n=== Database Cleanup ===');

    // First, show current stats
    final statsBefore = await _dbHelper.getDatabaseStatistics();
    print('Before cleanup:');
    print('- Albums: ${statsBefore.totalAlbums}');
    print('- Artists: ${statsBefore.totalArtists}');

    // Perform cleanup
    final cleanupResult = await _dbHelper.cleanupOrphanedRecords();

    print('\nCleanup completed:');
    print('- Deleted albums: ${cleanupResult.deletedAlbums}');
    print('- Deleted artists: ${cleanupResult.deletedArtists}');
    print('- Total deleted: ${cleanupResult.totalDeleted}');

    // Show stats after cleanup
    final statsAfter = await _dbHelper.getDatabaseStatistics();
    print('\nAfter cleanup:');
    print('- Albums: ${statsAfter.totalAlbums}');
    print('- Artists: ${statsAfter.totalArtists}');
  }

  /// Example 4: Performance testing
  Future<void> demonstratePerformance() async {
    print('\n=== Performance Testing ===');

    // Test single song insertion
    final singleSongStopwatch = Stopwatch()..start();
    await _dbHelper.insertSongWithAlbumAndArtists(
      song: Song(
        path: '/music/performance/test_single.mp3',
        source: AudioSourceEnum.local,
        title: 'Performance Test Single',
        trackNumber: 1,
        trackTotal: 1,
        duration: Duration(minutes: 3),
        performers: ['Performance Artist'],
        genres: ['Test'],
        discNumber: 1,
        totalDisc: 1,
      ),
      album: Album(title: 'Performance Test Album'),
      artists: [Artist(name: 'Performance Artist')],
    );
    singleSongStopwatch.stop();

    // Test batch insertion
    final batchSongs = List.generate(
      50,
      (i) => {
        'song': Song(
          path: '/music/performance/batch_$i.mp3',
          source: AudioSourceEnum.local,
          title: 'Batch Song $i',
          trackNumber: i + 1,
          trackTotal: 50,
          duration: Duration(minutes: 3),
          performers: ['Batch Artist'],
          genres: ['Test Batch'],
          discNumber: 1,
          totalDisc: 1,
        ),
        'album': Album(title: 'Batch Test Album'),
        'artists': [Artist(name: 'Batch Artist')],
      },
    );

    final batchStopwatch = Stopwatch()..start();
    await _dbHelper.insertMultipleSongsWithDetails(batchSongs);
    batchStopwatch.stop();

    print(
      'Single song insertion: ${singleSongStopwatch.elapsedMilliseconds}ms',
    );
    print(
      'Batch insertion (50 songs): ${batchStopwatch.elapsedMilliseconds}ms',
    );
    print(
      'Average per song in batch: ${(batchStopwatch.elapsedMilliseconds / 50).toStringAsFixed(2)}ms',
    );
  }

  /// Example 5: Error handling and recovery
  Future<void> demonstrateErrorHandling() async {
    print('\n=== Error Handling ===');

    // Test with invalid data
    final invalidSongs = [
      {
        'song': Song(
          path: '', // Invalid empty path
          source: AudioSourceEnum.local,
          title: 'Invalid Song 1',
          trackNumber: 0,
          trackTotal: 0,
          duration: Duration.zero,
          performers: [],
          genres: [],
          discNumber: 0,
          totalDisc: 0,
        ),
        'album': Album(title: 'Invalid Album'),
        'artists': [Artist(name: 'Invalid Artist')],
      },
      {
        'song': Song(
          path: '/music/valid/song.mp3',
          source: AudioSourceEnum.local,
          title: 'Valid Song',
          trackNumber: 1,
          trackTotal: 1,
          duration: Duration(minutes: 3),
          performers: ['Valid Artist'],
          genres: ['Pop'],
          discNumber: 1,
          totalDisc: 1,
        ),
        'album': Album(title: 'Valid Album'),
        'artists': [Artist(name: 'Valid Artist')],
      },
    ];

    try {
      final result = await _dbHelper.bulkImportSongs(
        songDataList: invalidSongs,
        chunkSize: 1, // Process one at a time to isolate errors
      );

      print('Error handling test completed:');
      print('- Successful: ${result.successCount}');
      print('- Failed: ${result.failureCount}');

      for (final error in result.failedSongs) {
        print('- Failed: ${error.songTitle} - ${error.error}');
      }
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  /// Helper method to generate random genres for testing
  List<String> _getRandomGenres(int seed) {
    final genres = [
      'Pop',
      'Rock',
      'Jazz',
      'Classical',
      'Electronic',
      'Hip Hop',
      'Country',
      'R&B',
    ];
    final Random random = Random(seed);
    final count = random.nextInt(3) + 1; // 1-3 genres
    final selectedGenres = <String>[];

    for (int i = 0; i < count; i++) {
      final genre = genres[random.nextInt(genres.length)];
      if (!selectedGenres.contains(genre)) {
        selectedGenres.add(genre);
      }
    }

    return selectedGenres;
  }

  /// Run all demonstrations
  Future<void> runAllDemonstrations() async {
    try {
      await demonstrateBulkImport();
      await demonstrateStatistics();
      await demonstrateCleanup();
      await demonstratePerformance();
      await demonstrateErrorHandling();

      print('\n=== All demonstrations completed successfully! ===');
    } catch (e) {
      print('Error running demonstrations: $e');
    }
  }
}

/// Utility class for database testing and validation
class DatabaseTestingUtils {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Validate database integrity
  static Future<bool> validateDatabaseIntegrity() async {
    try {
      // Check for orphaned records
      final songs = await _dbHelper.songProvider.getAllSongsWithDetails();
      final albums = await _dbHelper.albumProvider.getAll();
      final artists = await _dbHelper.artistProvider.getAll();

      print('Database integrity check:');
      print('- Songs: ${songs.length}');
      print('- Albums: ${albums.length}');
      print('- Artists: ${artists.length}');

      // Check for broken relationships
      int brokenRelationships = 0;
      for (final song in songs) {
        if (song.albumId != null && song.album?.id != song.albumId) {
          brokenRelationships++;
        }
      }

      if (brokenRelationships > 0) {
        print('WARNING: Found $brokenRelationships broken relationships');
        return false;
      }

      print('✓ Database integrity validated');
      return true;
    } catch (e) {
      print('Error validating database: $e');
      return false;
    }
  }

  /// Generate test data for development
  static Future<void> generateTestData({int songCount = 100}) async {
    print('Generating $songCount test songs...');

    final testData = <Map<String, dynamic>>[];
    final random = Random();

    for (int i = 0; i < songCount; i++) {
      testData.add({
        'song': Song(
          path: '/test/music/song_$i.mp3',
          source: AudioSourceEnum.local,
          title: 'Test Song $i',
          trackNumber: (i % 12) + 1,
          trackTotal: 12,
          duration: Duration(
            minutes: 2 + random.nextInt(4),
            seconds: random.nextInt(60),
          ),
          performers: ['Test Artist ${i ~/ 10}'],
          genres: ['Test Genre ${random.nextInt(5)}'],
          discNumber: 1,
          totalDisc: 1,
          year: 2020 + random.nextInt(4),
        ),
        'album': Album(
          title: 'Test Album ${i ~/ 10}',
          coverUri: 'https://example.com/test_covers/${i ~/ 10}.jpg',
          releaseDate: DateTime(2020 + random.nextInt(4)),
        ),
        'artists': [
          Artist(
            name: 'Test Artist ${i ~/ 10}',
            imageUri: 'https://example.com/test_artists/${i ~/ 10}.jpg',
            bio: 'Test bio for artist ${i ~/ 10}',
          ),
        ],
      });
    }

    final result = await _dbHelper.bulkImportSongs(songDataList: testData);
    print(
      'Test data generated: ${result.successCount} songs, ${result.failureCount} failures',
    );
  }
}

void main() async {
  final examples = DatabaseAdvancedExamples();
  await examples.runAllDemonstrations();

  // Validate database integrity
  final isValid = await DatabaseTestingUtils.validateDatabaseIntegrity();
  print('Database integrity check: ${isValid ? 'Passed' : 'Failed'}');

  // Generate test data
  await DatabaseTestingUtils.generateTestData(songCount: 50);
}
