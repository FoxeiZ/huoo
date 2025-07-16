import 'package:flutter/material.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/widgets/common/song_tile.dart';

class SearchResultItems {
  /// Build a song item using SongTile component
  static Widget buildSongItem({
    required BuildContext context,
    required Map<String, dynamic> songData,
    required Function(Song) onPlay,
    required Function(Song) onQueue,
  }) {
    final song = convertToSongModel(songData);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SongTile(
        song: song,
        onTap: () => onPlay(song),
        onPlayOptionPressed: onPlay,
        onQueueOptionPressed: onQueue,
      ),
    );
  }

  /// Build an artist item tile
  static Widget buildArtistItem({
    required BuildContext context,
    required Map<String, dynamic> artistData,
    required VoidCallback onTap,
  }) {
    final artist = convertToArtistModel(artistData);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1DB954).withOpacity(0.2),
          child: const Icon(Icons.person, color: Color(0xFF1DB954)),
        ),
        title: Text(
          artist.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${artistData['song_count'] ?? 0} song${(artistData['song_count'] ?? 0) != 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  /// Build an album card
  static Widget buildAlbumCard({
    required BuildContext context,
    required Map<String, dynamic> albumData,
    required VoidCallback onTap,
  }) {
    final album = convertToAlbumModel(albumData);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.album,
                  color: Color(0xFF1DB954),
                  size: 48,
                ),
              ),
            ),
            // Album Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        album.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      albumData['artist'] ?? 'Unknown Artist',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (albumData['year'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        albumData['year'].toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to convert API data to models
  static Song convertToSongModel(Map<String, dynamic> songData) {
    return Song(
      id: songData['id']?.hashCode ?? 0,
      path: songData['file_path'] ?? '',
      title: songData['title'] ?? 'Unknown Title',
      cover: null,
      duration: Duration(seconds: songData['duration'] ?? 0),
      trackNumber: songData['track_number'] ?? 1,
      trackTotal: 1,
      discNumber: 1,
      totalDisc: 1,
      year: songData['year'],
      genres: songData['genre'] != null ? [songData['genre']] : [],
    );
  }

  static Artist convertToArtistModel(Map<String, dynamic> artistData) {
    return Artist(
      id: artistData['id']?.hashCode ?? 0,
      name: artistData['name'] ?? 'Unknown Artist',
      imageUri: null,
      bio: null,
    );
  }

  static Album convertToAlbumModel(Map<String, dynamic> albumData) {
    return Album(
      id: albumData['id']?.hashCode ?? 0,
      title: albumData['title'] ?? 'Unknown Album',
      coverUri: null,
      releaseDate:
          albumData['year'] != null ? DateTime(albumData['year']) : null,
    );
  }
}
