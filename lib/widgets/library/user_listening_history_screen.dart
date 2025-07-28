import 'package:flutter/material.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/repositories/user_repository.dart';
import 'package:huoo/widgets/common/song_tile.dart';
import 'package:huoo/widgets/library/library_action_utils.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class ListeningHistoryScreen extends StatefulWidget {
  const ListeningHistoryScreen({super.key});

  @override
  State<ListeningHistoryScreen> createState() => _ListeningHistoryScreenState();
}

class _ListeningHistoryScreenState extends State<ListeningHistoryScreen> {
  final UserRepository _userRepository = UserRepository();
  List<Song> _historySongs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadListeningHistory();
  }

  Future<void> _loadListeningHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final historyMaps = await _userRepository.getListeningHistory();
      if (historyMaps != null) {
        _historySongs = historyMaps.map((map) => Song.fromMap(map)).toList();
      } else {
        _historySongs = [];
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load listening history: $e';
      _logger.e(
        'Error loading listening history',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening History'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              )
              : _errorMessage.isNotEmpty
              ? Center(
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
                      'Error Loading History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadListeningHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _historySongs.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Listening History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Play some songs to see your history here',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _historySongs.length,
                itemBuilder: (context, index) {
                  final song = _historySongs[index];
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
    );
  }
}
