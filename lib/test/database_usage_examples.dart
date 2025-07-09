// Example file showing how to properly insert songs, albums, and artists with relationships
// This file demonstrates best practices for using the DatabaseHelper methods

// ignore_for_file: avoid_print

import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';

class DatabaseUsageExamples {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Example 1: Insert a single song with album and artists
  Future<Song> insertSingleSong() async {
    // Create your entities
    final album = Album(
      title: 'Abbey Road',
      coverUri: 'https://example.com/abbey-road-cover.jpg',
      releaseDate: DateTime(1969, 9, 26),
    );

    final artists = [
      Artist(
        name: 'The Beatles',
        imageUri: 'https://example.com/beatles.jpg',
        bio: 'British rock band formed in Liverpool in 1960.',
      ),
    ];

    final song = Song(
      path: '/music/abbey-road/come-together.mp3',
      source: AudioSourceEnum.local,
      title: 'Come Together',
      trackNumber: 1,
      trackTotal: 17,
      duration: Duration(minutes: 4, seconds: 19),
      performers: ['The Beatles'],
      genres: ['Rock', 'Pop'],
      discNumber: 1,
      totalDisc: 1,
      year: 1969,
    );

    if (await _dbHelper.songProvider.getByItem(song) != null) {
      print('Song already exists in the database: ${song.title}');
      return (await _dbHelper.songProvider.getByItem(song))!;
    }

    // Insert with proper relationships - this is atomic!
    try {
      final insertedSong = await _dbHelper.insertSongWithAlbumAndArtists(
        song: song,
        album: album,
        artists: artists,
      );

      print('Successfully inserted song: ${insertedSong.title}');
      print('Song ID: ${insertedSong.id}');
      print('Album ID: ${insertedSong.albumId}');
      print('Artists: ${insertedSong.artists?.map((a) => a.name).join(', ')}');

      return insertedSong;
    } catch (e) {
      print('Error inserting song: $e');
      rethrow;
    }
  }

  /// Example 2: Insert multiple songs from the same album
  Future<List<Song>> insertAlbumWithSongs() async {
    final album = Album(
      title: 'Dark Side of the Moon',
      coverUri: 'https://example.com/dark-side-cover.jpg',
      releaseDate: DateTime(1973, 3, 1),
    );

    final artists = [
      Artist(
        name: 'Pink Floyd',
        imageUri: 'https://example.com/pink-floyd.jpg',
        bio: 'English rock band formed in London in 1965.',
      ),
    ];

    // Create multiple songs for the album
    final songDataList = [
      {
        'song': Song(
          path: '/music/dark-side/speak-to-me.mp3',
          source: AudioSourceEnum.local,
          title: 'Speak to Me',
          trackNumber: 1,
          trackTotal: 10,
          duration: Duration(minutes: 1, seconds: 30),
          performers: ['Pink Floyd'],
          genres: ['Progressive Rock'],
          discNumber: 1,
          totalDisc: 1,
          year: 1973,
        ),
        'album': album,
        'artists': artists,
      },
      {
        'song': Song(
          path: '/music/dark-side/breathe.mp3',
          source: AudioSourceEnum.local,
          title: 'Breathe (In the Air)',
          trackNumber: 2,
          trackTotal: 10,
          duration: Duration(minutes: 2, seconds: 43),
          performers: ['Pink Floyd'],
          genres: ['Progressive Rock'],
          discNumber: 1,
          totalDisc: 1,
          year: 1973,
        ),
        'album': album,
        'artists': artists,
      },
      {
        'song': Song(
          path: '/music/dark-side/time.mp3',
          source: AudioSourceEnum.local,
          title: 'Time',
          trackNumber: 4,
          trackTotal: 10,
          duration: Duration(minutes: 7, seconds: 6),
          performers: ['Pink Floyd'],
          genres: ['Progressive Rock'],
          discNumber: 1,
          totalDisc: 1,
          year: 1973,
        ),
        'album': album,
        'artists': artists,
      },
    ];

    try {
      final insertedSongs = await _dbHelper.insertMultipleSongsWithDetails(
        songDataList,
      );

      print('Successfully inserted ${insertedSongs.length} songs');
      for (final song in insertedSongs) {
        print('- ${song.title} (ID: ${song.id})');
      }

      return insertedSongs;
    } catch (e) {
      print('Error inserting multiple songs: $e');
      rethrow;
    }
  }

  /// Example 3: Insert a compilation album with multiple artists
  Future<List<Song>> insertCompilationAlbum() async {
    final album = Album(
      title: 'Now That\'s What I Call Music! 80',
      coverUri: 'https://example.com/now-80-cover.jpg',
      releaseDate: DateTime(2011, 11, 21),
    );

    // Multiple different artists for a compilation
    final artists = [
      Artist(name: 'Adele', imageUri: 'https://example.com/adele.jpg'),
      Artist(
        name: 'Bruno Mars',
        imageUri: 'https://example.com/bruno-mars.jpg',
      ),
      Artist(
        name: 'Katy Perry',
        imageUri: 'https://example.com/katy-perry.jpg',
      ),
    ];

    final songDataList = [
      {
        'song': Song(
          path: '/music/now-80/rolling-in-the-deep.mp3',
          source: AudioSourceEnum.local,
          title: 'Rolling in the Deep',
          trackNumber: 1,
          trackTotal: 40,
          duration: Duration(minutes: 3, seconds: 48),
          performers: ['Adele'],
          genres: ['Pop', 'Soul'],
          discNumber: 1,
          totalDisc: 2,
          year: 2010,
        ),
        'album': album,
        'artists': [artists[0]], // Only Adele for this song
      },
      {
        'song': Song(
          path: '/music/now-80/grenade.mp3',
          source: AudioSourceEnum.local,
          title: 'Grenade',
          trackNumber: 2,
          trackTotal: 40,
          duration: Duration(minutes: 3, seconds: 42),
          performers: ['Bruno Mars'],
          genres: ['Pop', 'R&B'],
          discNumber: 1,
          totalDisc: 2,
          year: 2010,
        ),
        'album': album,
        'artists': [artists[1]], // Only Bruno Mars for this song
      },
      {
        'song': Song(
          path: '/music/now-80/firework.mp3',
          source: AudioSourceEnum.local,
          title: 'Firework',
          trackNumber: 3,
          trackTotal: 40,
          duration: Duration(minutes: 3, seconds: 48),
          performers: ['Katy Perry'],
          genres: ['Pop', 'Dance'],
          discNumber: 1,
          totalDisc: 2,
          year: 2010,
        ),
        'album': album,
        'artists': [artists[2]], // Only Katy Perry for this song
      },
    ];

    try {
      final insertedSongs = await _dbHelper.insertMultipleSongsWithDetails(
        songDataList,
      );

      print(
        'Successfully inserted compilation album with ${insertedSongs.length} songs',
      );
      return insertedSongs;
    } catch (e) {
      print('Error inserting compilation album: $e');
      rethrow;
    }
  }

  /// Example 4: Handle duplicate detection
  Future<void> demonstrateDuplicateHandling() async {
    final album = Album(
      title: 'Test Album',
      coverUri: 'https://example.com/test.jpg',
      releaseDate: DateTime.now(),
    );

    final artist = Artist(
      name: 'Test Artist',
      imageUri: 'https://example.com/test-artist.jpg',
      bio: 'A test artist for demonstration.',
    );

    final song1 = Song(
      path: '/music/test/song1.mp3',
      source: AudioSourceEnum.local,
      title: 'Test Song 1',
      trackNumber: 1,
      trackTotal: 2,
      duration: Duration(minutes: 3),
      performers: ['Test Artist'],
      genres: ['Test'],
      discNumber: 1,
      totalDisc: 1,
    );

    final song2 = Song(
      path: '/music/test/song2.mp3',
      source: AudioSourceEnum.local,
      title: 'Test Song 2',
      trackNumber: 2,
      trackTotal: 2,
      duration: Duration(minutes: 3),
      performers: ['Test Artist'],
      genres: ['Test'],
      discNumber: 1,
      totalDisc: 1,
    );

    try {
      // Insert first song - this will create the album and artist
      final insertedSong1 = await _dbHelper.insertSongWithAlbumAndArtists(
        song: song1,
        album: album,
        artists: [artist],
      );
      print('First song inserted: ${insertedSong1.title}');

      // Insert second song - this will reuse the existing album and artist
      final insertedSong2 = await _dbHelper.insertSongWithAlbumAndArtists(
        song: song2,
        album: album, // Same album title - will be reused
        artists: [artist], // Same artist name - will be reused
      );
      print('Second song inserted: ${insertedSong2.title}');

      // Both songs should reference the same album and artist
      print(
        'Both songs have same album ID: ${insertedSong1.albumId == insertedSong2.albumId}',
      );
    } catch (e) {
      print('Error in duplicate handling demo: $e');
    }
  }

  /// Example 5: Handle errors gracefully
  Future<void> demonstrateErrorHandling() async {
    try {
      // This will fail because the song has invalid data
      final invalidSong = Song(
        path: '', // Empty path - this might cause issues
        source: AudioSourceEnum.local,
        title: '', // Empty title - this might cause issues
        trackNumber: 0,
        trackTotal: 0,
        duration: Duration.zero,
        performers: [],
        genres: [],
        discNumber: 0,
        totalDisc: 0,
      );

      await _dbHelper.insertSongWithAlbumAndArtists(
        song: invalidSong,
        album: Album(title: 'Test Album'),
        artists: [Artist(name: 'Test Artist')],
      );
    } catch (e) {
      print('Caught expected error: $e');
      // Handle the error appropriately in your app
      // Maybe show a user-friendly message or log the error
    }
  }

  /// Example 6: Query inserted data with relationships
  Future<void> demonstrateQuerying() async {
    // First, insert some test data
    await insertSingleSong();

    // Now query the data
    final allSongs = await _dbHelper.songProvider.getAllSongsWithDetails();

    print('Found ${allSongs.length} songs with complete details:');
    for (final song in allSongs) {
      print('Song: ${song.title}');
      print('  Album: ${song.album?.title ?? 'Unknown'}');
      print(
        '  Artists: ${song.artists?.map((a) => a.name).join(', ') ?? 'Unknown'}',
      );
      print('  Duration: ${song.duration.inSeconds} seconds');
      print('---');
    }
  }

  Future<void> ensureDatabaseInitialized() async {
    await _dbHelper.initialize();
  }
}

/// Helper class with static methods for common operations
class DatabaseQuickInsert {
  /// Quick method to insert a song from file metadata
  static Future<Song> fromMetadata({
    required String filePath,
    required String title,
    required String albumTitle,
    required List<String> artistNames,
    Duration? duration,
    int? trackNumber,
    int? year,
    List<String>? genres,
  }) async {
    final dbHelper = DatabaseHelper();

    // Create entities from metadata
    final album = Album(
      title: albumTitle,
      releaseDate: year != null ? DateTime(year) : null,
    );

    final artists = artistNames.map((name) => Artist(name: name)).toList();

    final song = Song(
      path: filePath,
      source: AudioSourceEnum.local,
      title: title,
      trackNumber: trackNumber ?? 1,
      trackTotal: 1,
      duration: duration ?? Duration.zero,
      performers: artistNames,
      genres: genres ?? [],
      discNumber: 1,
      totalDisc: 1,
      year: year,
    );

    return await dbHelper.insertSongWithAlbumAndArtists(
      song: song,
      album: album,
      artists: artists,
    );
  }
}

void runn() async {
  final dbExamples = DatabaseUsageExamples();
  await dbExamples.ensureDatabaseInitialized();

  // Example 1: Insert a single song
  await dbExamples.insertSingleSong();

  // Example 2: Insert multiple songs from the same album
  await dbExamples.insertAlbumWithSongs();

  // Example 3: Insert a compilation album with multiple artists
  await dbExamples.insertCompilationAlbum();

  // Example 4: Demonstrate duplicate handling
  await dbExamples.demonstrateDuplicateHandling();

  // Example 5: Demonstrate error handling
  await dbExamples.demonstrateErrorHandling();

  // Example 6: Query inserted data with relationships
  await dbExamples.demonstrateQuerying();

  // Quick insert from metadata
  final quickSong = await DatabaseQuickInsert.fromMetadata(
    filePath: '/music/quick/song.mp3',
    title: 'Quick Song',
    albumTitle: 'Quick Album',
    artistNames: ['Quick Artist'],
    duration: Duration(minutes: 3, seconds: 30),
    trackNumber: 1,
    year: 2023,
    genres: ['Pop'],
  );

  print('Quickly inserted song: ${quickSong.title}');
  print('Quick Song ID: ${quickSong.id}');
  print('Quick Album ID: ${quickSong.albumId}');
  print('Quick Artists: ${quickSong.artists?.map((a) => a.name).join(', ')}');
  // Close the database connection if needed
  // await dbExamples._dbHelper.close();
  print('Database usage examples completed successfully.');
  // Note: In a real application, you would handle database closing in a more structured way
}
