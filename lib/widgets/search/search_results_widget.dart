import 'package:flutter/material.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/api/api_models.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/widgets/search/search_result_items.dart';
import 'package:huoo/widgets/library/library_action_utils.dart';
import 'package:huoo/widgets/library/library_details_modal.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<SongSearchResult> songs;
  final List<ArtistSearchResult> artists;
  final List<AlbumSearchResult> albums;
  final String selectedFilter;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const SearchResultsWidget({
    super.key,
    required this.songs,
    required this.artists,
    required this.albums,
    required this.selectedFilter,
    required this.isLoading,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFilter == 'songs') {
      return _buildSongsOnlyResults(context);
    } else if (selectedFilter == 'artists') {
      return _buildArtistsOnlyResults(context);
    } else if (selectedFilter == 'albums') {
      return _buildAlbumsOnlyResults(context);
    } else {
      return _buildAllResults(context);
    }
  }

  Widget _buildAllResults(BuildContext context) {
    final bool hasResults =
        songs.isNotEmpty || artists.isNotEmpty || albums.isNotEmpty;

    if (!hasResults && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Songs Section
            if (songs.isNotEmpty) ...[
              _buildSectionHeader('Songs', songs.length),
              const SizedBox(height: 8),
              ...songs
                  .take(3)
                  .map(
                    (songData) => SearchResultItems.buildSongItem(
                      context: context,
                      songData: songData,
                      onPlay:
                          (song) => LibraryActionUtils.playSong(context, song),
                      onQueue:
                          (song) =>
                              LibraryActionUtils.addSongToQueue(context, song),
                    ),
                  ),
              if (songs.length > 3)
                _buildViewAllButton('View all ${songs.length} songs', () {
                  // Navigate to songs-only view
                }),
              const SizedBox(height: 24),
            ],

            // Artists Section
            if (artists.isNotEmpty) ...[
              _buildSectionHeader('Artists', artists.length),
              const SizedBox(height: 8),
              ...artists
                  .take(3)
                  .map(
                    (artistData) => SearchResultItems.buildArtistItem(
                      context: context,
                      artistData: artistData,
                      onTap:
                          () => _showArtistDetails(
                            context,
                            SearchResultItems.convertToArtistModel(artistData),
                            artistData,
                          ),
                    ),
                  ),
              if (artists.length > 3)
                _buildViewAllButton('View all ${artists.length} artists', () {
                  // Navigate to artists-only view
                }),
              const SizedBox(height: 24),
            ],

            // Albums Section
            if (albums.isNotEmpty) ...[
              _buildSectionHeader('Albums', albums.length),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final albumData = albums[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: SearchResultItems.buildAlbumCard(
                        context: context,
                        albumData: albumData,
                        onTap:
                            () => _showAlbumDetails(
                              context,
                              SearchResultItems.convertToAlbumModel(albumData),
                              albumData,
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsOnlyResults(BuildContext context) {
    if (songs.isEmpty && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No songs found',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == songs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            ),
          );
        }
        return SearchResultItems.buildSongItem(
          context: context,
          songData: songs[index],
          onPlay: (song) => LibraryActionUtils.playSong(context, song),
          onQueue: (song) => LibraryActionUtils.addSongToQueue(context, song),
        );
      },
    );
  }

  Widget _buildArtistsOnlyResults(BuildContext context) {
    if (artists.isEmpty && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No artists found',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artists.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == artists.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            ),
          );
        }
        return SearchResultItems.buildArtistItem(
          context: context,
          artistData: artists[index],
          onTap:
              () => _showArtistDetails(
                context,
                SearchResultItems.convertToArtistModel(artists[index]),
                artists[index],
              ),
        );
      },
    );
  }

  Widget _buildAlbumsOnlyResults(BuildContext context) {
    if (albums.isEmpty && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.album, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No albums found',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == albums.length) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1DB954)),
          );
        }
        return SearchResultItems.buildAlbumCard(
          context: context,
          albumData: albums[index],
          onTap:
              () => _showAlbumDetails(
                context,
                SearchResultItems.convertToAlbumModel(albums[index]),
                albums[index],
              ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildViewAllButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1DB954),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Song _convertSongResponseToSong(SongResponse songResponse) {
    final artists =
        songResponse.artistNames.map((name) => Artist(name: name)).toList();

    return Song(
      id: null,
      apiId: songResponse.id,
      path: songResponse.path,
      source: AudioSourceEnum.api,
      cover: songResponse.cover,
      albumId: null,
      year: songResponse.year,
      title: songResponse.title,
      trackNumber: songResponse.trackNumber,
      trackTotal: songResponse.trackTotal,
      duration:
          songResponse.duration != null
              ? Duration(seconds: songResponse.duration!)
              : const Duration(seconds: 0),
      genres: songResponse.genres,
      discNumber: songResponse.discNumber,
      totalDisc: songResponse.totalDisc,
      lyrics: songResponse.lyrics,
      rating: songResponse.rating,
      playCount: songResponse.playCount,
      dateAdded:
          songResponse.createdAt != null
              ? DateTime.tryParse(songResponse.createdAt!)
              : null,
      lastPlayed: null,
      artists: artists,
      album: null,
    );
  }

  // Detail modal methods
  void _showArtistDetails(
    BuildContext context,
    Artist artist,
    ArtistSearchResult artistData,
  ) {
    LibraryDetailsModal.showArtistDetails(
      context,
      artist,
      artistData.songs.map((song) => _convertSongResponseToSong(song)).toList(),
      onSongTap:
          (songs, index) => LibraryActionUtils.playSongs(context, songs, index),
      onSongPlay: (song) => LibraryActionUtils.playSong(context, song),
      onSongQueue: (song) => LibraryActionUtils.addSongToQueue(context, song),
      onPlayAll: (songs) => LibraryActionUtils.playSongs(context, songs),
    );
  }

  void _showAlbumDetails(
    BuildContext context,
    Album album,
    AlbumSearchResult albumData,
  ) {
    LibraryDetailsModal.showAlbumDetails(
      context,
      album,
      albumData.songs.map((song) => _convertSongResponseToSong(song)).toList(),
      onSongTap:
          (songs, index) => LibraryActionUtils.playSongs(context, songs, index),
      onSongPlay: (song) => LibraryActionUtils.playSong(context, song),
      onSongQueue: (song) => LibraryActionUtils.addSongToQueue(context, song),
      onPlayAll: (songs) => LibraryActionUtils.playSongs(context, songs),
      onShuffle: (songs) => LibraryActionUtils.shufflePlay(context, songs),
    );
  }
}
