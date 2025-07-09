import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/screens/main_player.dart';
import 'package:huoo/widgets/common/song_tile.dart';

class ArtistsListWidget extends StatefulWidget {
  const ArtistsListWidget({super.key});

  @override
  State<ArtistsListWidget> createState() => _ArtistsListWidgetState();
}

class _ArtistsListWidgetState extends State<ArtistsListWidget> {
  List<Artist> _artists = [];
  Map<int, List<Song>> _artistSongs = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final artists = await DatabaseHelper().artistProvider.getAll();
      final Map<int, List<Song>> artistSongs = {};

      // Get songs for each artist
      for (final artist in artists) {
        if (artist.id != null) {
          final songs = await DatabaseHelper().songProvider
              .getSongsByArtistWithDetails(artist.id!);
          artistSongs[artist.id!] = songs;
        }
      }

      if (mounted) {
        setState(() {
          _artists = artists;
          _artistSongs = artistSongs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load artists: $e';
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
              'Error Loading Artists',
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
              onPressed: _loadArtists,
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

    if (_artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Artists Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add music folders and scan to see your artists here',
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
      onRefresh: _loadArtists,
      color: const Color(0xFF1DB954),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _artists.length,
        itemBuilder: (context, index) {
          final artist = _artists[index];
          final songs = _artistSongs[artist.id] ?? [];
          return _buildArtistTile(artist, songs);
        },
      ),
    );
  }

  Widget _buildArtistTile(Artist artist, List<Song> songs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          '${songs.length} song${songs.length != 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: () => _showArtistOptions(artist, songs),
        ),
        onTap: () => _showArtistDetails(artist, songs),
      ),
    );
  }

  void _showArtistDetails(Artist artist, List<Song> songs) {
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
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(
                              0xFF1DB954,
                            ).withValues(alpha: 0.2),
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
                                  artist.name,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Play All Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _playAllSongs(songs);
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
                      ),
                      const SizedBox(height: 16),
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
                            return SongTile(
                              song: song,
                              onTap: () {
                                Navigator.pop(context);
                                _playAllSongs(songs, index);
                              },
                              onMorePressed: () => _showSongOptions(song),
                              formatDuration: _formatDuration,
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

  void _showArtistOptions(Artist artist, List<Song> songs) {
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
                    'Play All',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _playAllSongs(songs);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shuffle, color: Colors.white),
                  title: const Text(
                    'Shuffle Play',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _shufflePlaySongs(songs);
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
                    // TODO: Add to queue
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title: const Text(
                    'Artist Info',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showArtistInfo(artist, songs);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _playSong(Song song) {
    // Add song to the audio player bloc and start playing
    context.read<AudioPlayerBloc>().add(AudioPlayerClearPlaylistEvent());
    context.read<AudioPlayerBloc>().add(AudioPlayerAddSongEvent(song));
    context.read<AudioPlayerBloc>().add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  void _playAllSongs(List<Song> songs, [int startIndex = 0]) {
    if (songs.isEmpty) return;

    context.read<AudioPlayerBloc>().add(
      AudioPlayerLoadPlaylistEvent(songs, initialIndex: startIndex),
    );
    context.read<AudioPlayerBloc>().add(AudioPlayerPlayEvent());
    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

  void _addToQueue(Song song) {
    final bloc = context.read<AudioPlayerBloc>();
    bloc.add(AudioPlayerAddSongEvent(song));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${song.title}" to queue'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1DB954),
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
                if (song.album != null)
                  _buildInfoRow('Album', song.album!.title),
                if (song.year != null)
                  _buildInfoRow('Year', song.year.toString()),
                _buildInfoRow('Track', '${song.trackNumber}'),
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

  void _shufflePlaySongs(List<Song> songs) {
    if (songs.isEmpty) return;

    // Create a shuffled copy of the songs
    final shuffledSongs = List<Song>.from(songs)..shuffle();

    // Clear playlist and add shuffled songs
    context.read<AudioPlayerBloc>().add(AudioPlayerClearPlaylistEvent());

    for (final song in shuffledSongs) {
      context.read<AudioPlayerBloc>().add(AudioPlayerAddSongEvent(song));
    }

    context.read<AudioPlayerBloc>().add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  void _showArtistInfo(Artist artist, List<Song> songs) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Artist Information',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', artist.name),
                _buildInfoRow('Songs', '${songs.length}'),
                if (songs.isNotEmpty) ...[
                  _buildInfoRow(
                    'Albums',
                    _getUniqueAlbumCount(songs).toString(),
                  ),
                  _buildInfoRow('Total Duration', _getTotalDuration(songs)),
                ],
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

  int _getUniqueAlbumCount(List<Song> songs) {
    return songs.map((song) => song.album?.title ?? 'Unknown').toSet().length;
  }

  String _getTotalDuration(List<Song> songs) {
    final totalSeconds = songs.fold<int>(
      0,
      (sum, song) => sum + song.duration.inSeconds,
    );
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
