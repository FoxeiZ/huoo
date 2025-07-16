import 'package:flutter/material.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/services/songs_cache.dart';
import 'package:huoo/widgets/common/cache_status_widget.dart';
import 'package:huoo/widgets/common/song_tile.dart';
import 'library_action_utils.dart';

class SongsListWidget extends StatefulWidget {
  const SongsListWidget({super.key});

  @override
  State<SongsListWidget> createState() => _SongsListWidgetState();
}

class _SongsListWidgetState extends State<SongsListWidget> {
  List<Song> _songs = [];
  bool _isLoading = true;
  String _error = '';
  final SongsCache _songsCache = SongsCache();

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final songs = await _songsCache.getSongs(forceRefresh: forceRefresh);

      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load songs: $e';
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
            const Text(
              'Error Loading Songs',
              style: TextStyle(
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
              onPressed: () => _loadSongs(forceRefresh: true),
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

    if (_songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Songs Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add music folders and scan to see your songs here',
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
      onRefresh: () => _loadSongs(forceRefresh: true),
      color: const Color(0xFF1DB954),
      child: Column(
        children: [
          CacheStatusWidget(onRefresh: () => _loadSongs(forceRefresh: true)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return SongTile(
                  song: song,
                  onTap: () => LibraryActionUtils.playSong(context, song),
                  onPlayOptionPressed:
                      (song) => LibraryActionUtils.playSong(context, song),
                  onQueueOptionPressed:
                      (song) =>
                          LibraryActionUtils.addSongToQueue(context, song),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
