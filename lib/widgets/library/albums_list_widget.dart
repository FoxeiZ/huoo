import 'package:flutter/material.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/services/albums_cache.dart';
import 'package:huoo/widgets/common/cache_status_widget.dart';
import 'library_details_modal.dart';
import 'library_action_utils.dart';

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
  final AlbumsCache _albumsCache = AlbumsCache();

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final result = await _albumsCache.getAlbums(forceRefresh: forceRefresh);
      final albums = result['albums'] as List<Album>;
      final albumSongs = result['albumSongs'] as Map<int, List<Song>>;

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
      onRefresh: () => _loadAlbums(forceRefresh: true),
      color: const Color(0xFF1DB954),
      child: Column(
        children: [
          CacheStatusWidget(onRefresh: () => _loadAlbums(forceRefresh: true)),
          Expanded(
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
          ),
        ],
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumDetails(Album album, List<Song> songs) {
    LibraryDetailsModal.showAlbumDetails(
      context,
      album,
      songs,
      onSongTap:
          (songs, index) => LibraryActionUtils.playSongs(context, songs, index),
      onSongPlay: (song) => LibraryActionUtils.playSong(context, song),
      onSongQueue: (song) => LibraryActionUtils.addSongToQueue(context, song),
      onPlayAll: (songs) => LibraryActionUtils.playSongs(context, songs),
      onShuffle: (songs) => LibraryActionUtils.shufflePlay(context, songs),
    );
  }
}
