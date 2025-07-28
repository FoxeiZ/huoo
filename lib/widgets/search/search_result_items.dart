import 'package:flutter/material.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/api/api_models.dart';
import 'package:huoo/widgets/common/song_tile.dart';

class SearchResultItems {
  static Widget buildSongItem({
    required BuildContext context,
    required SongSearchResult songData,
    required Function(Song) onPlay,
    required Function(Song) onQueue,
  }) {
    final song = convertToSongModel(songData);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SongTile(
        song: song,
        onTap: () => onPlay(song),
        onPlayOptionPressed: onPlay,
        onQueueOptionPressed: onQueue,
      ),
    );
  }

  static Widget buildArtistItem({
    required BuildContext context,
    required ArtistSearchResult artistData,
    required VoidCallback onTap,
  }) {
    final artist = convertToArtistModel(artistData);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
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
          '${artistData.songCount} song${artistData.songCount != 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  static Widget buildAlbumCard({
    required BuildContext context,
    required AlbumSearchResult albumData,
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
                  color: const Color(0xFF1DB954).withValues(alpha: 0.2),
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
                      albumData.artist ?? 'Unknown Artist',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (albumData.year != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        albumData.year.toString(),
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

  static Song convertToSongModel(SongSearchResult songData) {
    return Song(
      id: null,
      apiId: songData.id,
      path: songData.path,
      source: AudioSourceEnum.api,
      cover: songData.cover,
      albumId: null,
      year: songData.year,
      title: songData.title,
      trackNumber: 1,
      trackTotal: 1,
      duration:
          songData.duration != null
              ? Duration(seconds: songData.duration!)
              : const Duration(seconds: 0),
      genres: songData.genres,
      discNumber: 1,
      totalDisc: 1,
      artists:
          songData.artist
              ?.split(',')
              .map((e) => Artist(name: e.trim()))
              .toList() ??
          [],
      album: null,
    );
  }

  static Artist convertToArtistModel(ArtistSearchResult artistData) {
    return Artist(
      id: artistData.id.hashCode,
      name: artistData.name,
      imageUri: null,
      bio: null,
    );
  }

  static Album convertToAlbumModel(AlbumSearchResult albumData) {
    return Album(
      id: albumData.id.hashCode,
      title: albumData.title,
      coverUri: null,
      releaseDate: albumData.year != null ? DateTime(albumData.year!) : null,
    );
  }
}
