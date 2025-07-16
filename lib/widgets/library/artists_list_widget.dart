import 'package:flutter/material.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/services/artists_cache.dart';
import 'package:huoo/widgets/common/cache_status_widget.dart';
import 'package:huoo/widgets/common/song_tile.dart';
import 'library_details_modal.dart';
import 'library_action_utils.dart';

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
  final ArtistsCache _artistsCache = ArtistsCache();

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final result = await _artistsCache.getArtists(forceRefresh: forceRefresh);
      final artists = result['artists'] as List<Artist>;
      final artistSongs = result['artistSongs'] as Map<int, List<Song>>;

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
      onRefresh: () => _loadArtists(forceRefresh: true),
      color: const Color(0xFF1DB954),
      child: Column(
        children: [
          CacheStatusWidget(onRefresh: () => _loadArtists(forceRefresh: true)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _artists.length,
              itemBuilder: (context, index) {
                final artist = _artists[index];
                final songs = _artistSongs[artist.id] ?? [];
                return _buildArtistTile(artist, songs);
              },
            ),
          ),
        ],
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
          onPressed:
              () => showSongsOptions(
                context,
                artist,
                songs,
                onAddToQueuePressed:
                    (songs) =>
                        LibraryActionUtils.addSongsToQueue(context, songs),
                onPlayAllPressed:
                    (songs) => LibraryActionUtils.playSongs(context, songs),
                onShufflePressed:
                    (songs) => LibraryActionUtils.shufflePlay(context, songs),
              ),
        ),
        onTap: () => _showArtistDetails(artist, songs),
      ),
    );
  }

  void _showArtistDetails(Artist artist, List<Song> songs) {
    LibraryDetailsModal.showArtistDetails(
      context,
      artist,
      songs,
      onSongTap:
          (songs, index) => LibraryActionUtils.playSongs(context, songs, index),
      onSongPlay: (song) => LibraryActionUtils.playSong(context, song),
      onSongQueue: (song) => LibraryActionUtils.addSongToQueue(context, song),
      onPlayAll: (songs) => LibraryActionUtils.playSongs(context, songs),
    );
  }
}
