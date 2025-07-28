import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:huoo/bloc/auth_bloc.dart';
import 'package:huoo/screens/profile_screen.dart';
import 'package:huoo/screens/settings_screen.dart';
import 'package:huoo/services/auth_service.dart';
import 'package:huoo/services/home_api_service.dart';
import 'package:huoo/models/api/api_models.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/widgets/library/library_action_utils.dart';
import 'package:logger/logger.dart';
import 'package:huoo/widgets/library/user_listening_history_screen.dart';
import 'package:huoo/widgets/library/library_details_modal.dart';

final Logger log = Logger();

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeApiService _homeApiService = HomeApiService();

  HomeScreenData? _homeData;
  List<ContinueListeningItem> _continueListening = [];
  List<TopMixItem> _topMixes = [];
  List<RecentListeningItem> _recentListening = [];
  List<SongResponse> _recommendedSongs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final homeData = await _homeApiService.getHomeScreenData();

      final recommendedSongsResponse = await _homeApiService
          .getRecommendedSongs(limit: 10);

      setState(() {
        _homeData = homeData;

        _continueListening = homeData.continueListening;
        _topMixes = homeData.topMixes;
        _recentListening = homeData.recentListening;

        _recommendedSongs =
            recommendedSongsResponse.songs
                .map(
                  (songData) =>
                      SongResponse.fromJson(songData as Map<String, dynamic>),
                )
                .toList();

        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        log.e('Error loading home data: $e', stackTrace: stackTrace);
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadHomeData();
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey;
    }

    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromRGBO(134, 200, 194, 1).withValues(alpha: 0.6),
              const Color(0xFF7BEEFF).withValues(alpha: 0.04),
              Colors.grey.shade900.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.25, 0.5],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? _buildErrorState()
                  : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [_buildAppBar(), _buildContent()],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to load home data',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final greetingMessage = _homeData?.greetingMessage ?? 'Welcome back!';
    final displayName = _homeData?.userDisplayName ?? 'Music Lover';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromRGBO(134, 200, 194, 1),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create:
                              (context) =>
                                  AuthBloc(authService: AuthService())
                                    ..add(AppStarted()),
                          child: const ProfileScreen(),
                        ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListeningHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildContinueListeningSection(),
          const SizedBox(height: 32),
          _buildTopMixesSection(),
          const SizedBox(height: 32),
          _buildRecentListeningSection(),
          const SizedBox(height: 32),
          _buildRecommendedSongsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildContinueListeningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Continue Listening",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children:
              _continueListening.map((item) {
                return _buildContinueListeningItem(
                  item.title,
                  _parseColor(item.color),
                  isReleased: item.isNewRelease,
                  progress: item.progressPercentage,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopMixesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Top Mixes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topMixes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mix = _topMixes[index];
              return _buildTopMixItem(mix);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentListeningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Based on your recent listening",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recentListening.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _recentListening[index];
              return _buildRecentListeningItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueListeningItem(
    String title,
    Color color, {
    bool isReleased = false,
    double progress = 0.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isReleased)
                          const Text(
                            "NEW RELEASE",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (progress > 0)
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Song _convertSongResponseToSong(SongResponse songResponseModel) {
    final artists =
        songResponseModel.artistNames
            .map((name) => Artist(name: name))
            .toList();

    return Song(
      id: null,
      apiId: songResponseModel.id,
      path: songResponseModel.path,
      source: AudioSourceEnum.api,
      cover: songResponseModel.cover,
      albumId: null,
      year: songResponseModel.year,
      title: songResponseModel.title,
      trackNumber: songResponseModel.trackNumber,
      trackTotal: songResponseModel.trackTotal,
      duration:
          songResponseModel.duration != null
              ? Duration(seconds: songResponseModel.duration!)
              : const Duration(seconds: 0),
      genres: songResponseModel.genres,
      discNumber: songResponseModel.discNumber,
      totalDisc: songResponseModel.totalDisc,
      lyrics: songResponseModel.lyrics,
      rating: songResponseModel.rating,
      playCount: songResponseModel.playCount,
      dateAdded:
          songResponseModel.createdAt != null
              ? DateTime.tryParse(songResponseModel.createdAt!)
              : null,
      lastPlayed: null,
      artists: artists,
      album: null,
    );
  }

  Widget _buildTopMixItem(TopMixItem item) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: () {
          LibraryDetailsModal.showDetailsGeneric(
            context,
            item.title,
            item.songs.map((song) => _convertSongResponseToSong(song)).toList(),
            onSongTap:
                (songs, index) =>
                    LibraryActionUtils.playSongs(context, songs, index),
            onSongPlay: (song) => LibraryActionUtils.playSong(context, song),
            onSongQueue:
                (song) => LibraryActionUtils.addSongToQueue(context, song),
            onPlayAll: (songs) => LibraryActionUtils.playSongs(context, songs),
            onShuffle:
                (songs) => LibraryActionUtils.shufflePlay(context, songs),
            imageUrl: item.imageUrl,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                    if (item.songCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.songCount} songs',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _parseColor(item.color),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.description != null) ...[
              const SizedBox(height: 2),
              Text(
                item.description!,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentListeningItem(RecentListeningItem item) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        width: 140,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),

                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          // Handle tap for recent listening item
                          // You can add navigation or playback logic here
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.artist ?? 'Unknown Artist',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSongsSection() {
    if (_recommendedSongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended for you",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedSongs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final song = _recommendedSongs[index];
              return _buildRecommendedSongItem(song);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongItem(SongResponse song) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  if (song.cover != null && song.cover!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.cover!,
                        width: 140,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),

                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          final convertedSong = _convertSongResponseToSong(
                            song,
                          );
                          LibraryActionUtils.playSong(context, convertedSong);
                        },
                        onLongPress: () {
                          final convertedSong = _convertSongResponseToSong(
                            song,
                          );
                          LibraryActionUtils.addSongToQueue(
                            context,
                            convertedSong,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (song.duration != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatDuration(song.duration!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            song.artistNames.isNotEmpty
                ? song.artistNames.join(', ')
                : 'Unknown Artist',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
