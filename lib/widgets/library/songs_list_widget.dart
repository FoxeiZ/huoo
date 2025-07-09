import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/screens/main_player.dart';
import 'package:huoo/widgets/common/song_tile.dart';

class SongsListWidget extends StatefulWidget {
  const SongsListWidget({super.key});

  @override
  State<SongsListWidget> createState() => _SongsListWidgetState();
}

class _SongsListWidgetState extends State<SongsListWidget> {
  List<Song> _songs = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final songs =
          await DatabaseHelper().songProvider.getAllSongsWithDetails();

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
            Text(
              'Error Loading Songs',
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
              onPressed: _loadSongs,
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
      onRefresh: _loadSongs,
      color: const Color(0xFF1DB954),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return SongTile(
            song: song,
            onTap: () => _playSong(song),
            onMorePressed: () => _showSongOptions(song),
            formatDuration: _formatDuration,
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _playSong(Song song) {
    context.read<AudioPlayerBloc>().add(
      AudioPlayerLoadPlaylistEvent([song], autoPlay: true),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  void _addToQueue(Song song) {
    context.read<AudioPlayerBloc>().add(AudioPlayerAddSongEvent(song));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${song.title}" to queue'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.white),
                  title: const Text(
                    'Play',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _playSong(song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.queue_music, color: Colors.white),
                  title: const Text(
                    'Add to Queue',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _addToQueue(song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.white),
                  title: const Text(
                    'Add to Playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Add to playlist
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title: const Text(
                    'Song Info',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSongInfo(song);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSongInfo(Song song) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Song Information',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Title', song.title),
                _buildInfoRow(
                  'Artist',
                  song.artist.isNotEmpty ? song.artist : 'Unknown',
                ),
                _buildInfoRow('Duration', _formatDuration(song.duration)),
                _buildInfoRow('Path', song.path),
                _buildInfoRow('Source', song.source.toString()),
                _buildInfoRow(
                  'Date Added',
                  song.dateAdded.toString().split(' ')[0],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF1DB954)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
