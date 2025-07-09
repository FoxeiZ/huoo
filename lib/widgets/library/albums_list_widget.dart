import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/screens/main_player.dart';

class AlbumsListWidget extends StatefulWidget {
  const AlbumsListWidget({super.key});

  @override
  State<AlbumsListWidget> createState() => _AlbumsListWidgetState();
}

class _AlbumsListWidgetState extends State<AlbumsListWidget> {
  List<Album> _albums = [];
  Map<int, List<Song>> _albumSongs = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final albums = await DatabaseHelper().albumProvider.getAll();
      final Map<int, List<Song>> albumSongs = {};

      // Get songs for each album
      for (final album in albums) {
        if (album.id != null) {
          final songs = await DatabaseHelper().songProvider
              .getSongsByAlbumWithDetails(album.id!);
          albumSongs[album.id!] = songs;
        }
      }

      if (mounted) {
        setState(() {
          _albums = albums;
          _albumSongs = albumSongs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load albums: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Albums',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAlbums,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Albums Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add music folders and scan to see your albums here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      color: const Color(0xFF1DB954),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          final songs = _albumSongs[album.id] ?? [];
          return _buildAlbumCard(album, songs);
        },
      ),
    );
  }

  Widget _buildAlbumCard(Album album, List<Song> songs) {
    // Get the first song's cover as album cover
    String? albumCover;
    if (songs.isNotEmpty && songs.first.cover != null) {
      albumCover = songs.first.cover;
    }

    return GestureDetector(
      onTap: () => _showAlbumDetails(album, songs),
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
                child:
                    albumCover != null && albumCover.isNotEmpty
                        ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.asset(
                            albumCover,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.album,
                                color: Color(0xFF1DB954),
                                size: 48,
                              );
                            },
                          ),
                        )
                        : const Icon(
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
                  children: [
                    Text(
                      album.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${songs.length} song${songs.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (album.releaseDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        album.releaseDate!.year.toString(),
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

  void _showAlbumDetails(Album album, List<Song> songs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1DB954,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                songs.isNotEmpty && songs.first.cover != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        songs.first.cover!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.album,
                                            color: Color(0xFF1DB954),
                                            size: 32,
                                          );
                                        },
                                      ),
                                    )
                                    : const Icon(
                                      Icons.album,
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
                                  album.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${songs.length} song${songs.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (album.releaseDate != null)
                                  Text(
                                    album.releaseDate!.year.toString(),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Play buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _playAlbum(songs);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _shuffleAlbum(songs);
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Songs List
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
                            return ListTile(
                              leading: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text(
                                song.title,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.performers.isNotEmpty
                                    ? song.performers.first
                                    : 'Unknown Artist',
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  // TODO: Show song options
                                },
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _playSong(song);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _playSong(Song song) {
    final bloc = context.read<AudioPlayerBloc>();

    // Add song to the audio player bloc and start playing
    bloc.add(AudioPlayerClearPlaylistEvent());
    bloc.add(AudioPlayerAddSongEvent(song));
    bloc.add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  void _playAlbum(List<Song> songs, [int startIndex = 0]) {
    if (songs.isEmpty) return;

    final bloc = context.read<AudioPlayerBloc>();

    // Clear playlist and add all album songs
    bloc.add(AudioPlayerClearPlaylistEvent());

    // Add songs to playlist starting from startIndex
    for (int i = startIndex; i < songs.length; i++) {
      bloc.add(AudioPlayerAddSongEvent(songs[i]));
    }

    // Add remaining songs from beginning if startIndex > 0
    for (int i = 0; i < startIndex; i++) {
      bloc.add(AudioPlayerAddSongEvent(songs[i]));
    }

    bloc.add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  void _shuffleAlbum(List<Song> songs) {
    if (songs.isEmpty) return;

    final bloc = context.read<AudioPlayerBloc>();

    // Create a shuffled copy of the songs
    final shuffledSongs = List<Song>.from(songs)..shuffle();

    // Clear playlist and add shuffled songs
    bloc.add(AudioPlayerClearPlaylistEvent());

    for (final song in shuffledSongs) {
      bloc.add(AudioPlayerAddSongEvent(song));
    }

    bloc.add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }
}
