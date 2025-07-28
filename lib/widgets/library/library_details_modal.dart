import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../common/song_tile.dart';

class LibraryDetailsModal extends StatelessWidget {
  final String title;
  final Widget header;
  final List<Song> songs;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;
  final Function(List<Song>, int)? onSongTap;
  final Function(Song)? onSongPlay;
  final Function(Song)? onSongQueue;

  const LibraryDetailsModal({
    super.key,
    required this.title,
    required this.header,
    required this.songs,
    this.onPlayAll,
    this.onShuffle,
    this.onSongTap,
    this.onSongPlay,
    this.onSongQueue,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                header,
                const SizedBox(height: 16),

                // Action buttons
                _buildActionButtons(context),
                const SizedBox(height: 24),

                // Songs list
                const Text(
                  'Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          Navigator.pop(context);
                          onSongTap?.call(songs, index);
                        },
                        onPlayOptionPressed: onSongPlay,
                        onQueueOptionPressed: onSongQueue,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (onPlayAll == null && onShuffle == null) {
      return const SizedBox.shrink();
    }

    if (onShuffle == null) {
      // Only Play All button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onPlayAll?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play All'),
        ),
      );
    }

    // Both Play and Shuffle buttons
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onPlayAll?.call();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onShuffle?.call();
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Shuffle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }

  static void showAlbumDetails(
    BuildContext context,
    Album album,
    List<Song> songs, {
    required Function(List<Song>, int) onSongTap,
    required Function(Song) onSongPlay,
    required Function(Song) onSongQueue,
    required Function(List<Song>) onPlayAll,
    required Function(List<Song>) onShuffle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => LibraryDetailsModal(
            title: album.title,
            header: _buildAlbumHeader(album, songs),
            songs: songs,
            onPlayAll: () => onPlayAll(songs),
            onShuffle: () => onShuffle(songs),
            onSongTap: onSongTap,
            onSongPlay: onSongPlay,
            onSongQueue: onSongQueue,
          ),
    );
  }

  static void showArtistDetails(
    BuildContext context,
    Artist artist,
    List<Song> songs, {
    required Function(List<Song>, int) onSongTap,
    required Function(Song) onSongPlay,
    required Function(Song) onSongQueue,
    required Function(List<Song>) onPlayAll,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => LibraryDetailsModal(
            title: artist.name,
            header: _buildArtistHeader(artist, songs),
            songs: songs,
            onPlayAll: () => onPlayAll(songs),
            onSongTap: onSongTap,
            onSongPlay: onSongPlay,
            onSongQueue: onSongQueue,
          ),
    );
  }

  static void showDetailsGeneric(
    BuildContext context,
    String title,
    List<Song> songs, {
    required Function(List<Song>, int) onSongTap,
    required Function(Song) onSongPlay,
    required Function(Song) onSongQueue,
    required Function(List<Song>) onPlayAll,
    required Function(List<Song>) onShuffle,
    String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => LibraryDetailsModal(
            title: title,
            header: _buildGenericHeader(title, songs, imageUrl: imageUrl),
            songs: songs,
            onPlayAll: () => onPlayAll(songs),
            onShuffle: () => onShuffle(songs),
            onSongTap: onSongTap,
            onSongPlay: onSongPlay,
            onSongQueue: onSongQueue,
          ),
    );
  }

  static Widget _buildAlbumHeader(Album album, List<Song> songs) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              songs.isNotEmpty && songs.first.cover != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      songs.first.cover!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.album,
                          color: Color(0xFF1DB954),
                          size: 32,
                        );
                      },
                    ),
                  )
                  : const Icon(Icons.album, color: Color(0xFF1DB954), size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${songs.length} song${songs.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (album.releaseDate != null)
                Text(
                  album.releaseDate!.year.toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildArtistHeader(Artist artist, List<Song> songs) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: Color(0xFF1DB954), size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artist.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${songs.length} song${songs.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildGenericHeader(
    String title,
    List<Song> songs, {
    String? imageUrl,
  }) {
    return Row(
      children: [
        imageUrl != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.music_note,
                    color: Color(0xFF1DB954),
                    size: 32,
                  );
                },
              ),
            )
            : CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                color: Color(0xFF1DB954),
                size: 32,
              ),
            ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${songs.length} song${songs.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
