import 'package:flutter/material.dart';
import 'package:huoo/repositories/user_repository.dart';
import 'package:huoo/services/user_api_service.dart';
import 'package:huoo/services/search_api_service.dart';
import 'package:huoo/services/home_api_service.dart';
import 'package:huoo/services/song_api_service.dart';
import 'package:huoo/services/playlist_api_service.dart';
import 'package:huoo/services/api_service.dart'; // For ApiConfig

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final UserRepository _userRepository = UserRepository();
  final UserApiService _userApiService = UserApiService();
  final SearchApiService _searchApiService = SearchApiService();
  final HomeApiService _homeApiService = HomeApiService();
  final SongApiService _songApiService = SongApiService();
  final PlaylistApiService _playlistApiService = PlaylistApiService();

  String _output = '';
  bool _isLoading = false;

  void _addOutput(String message) {
    setState(() {
      _output += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing API health...');
      final isHealthy = await _userRepository.checkApiHealth();
      _addOutput('Health check result: ${isHealthy ? 'HEALTHY' : 'UNHEALTHY'}');
    } catch (e) {
      _addOutput('Health check error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testProtectedEndpoint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing protected endpoint...');
      final result = await _userApiService.testProtectedEndpoint();
      _addOutput('Protected endpoint success: ${result.toString()}');
    } catch (e) {
      _addOutput('Protected endpoint error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testGetUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Getting user profile from API...');
      final profile = await _userRepository.getUserProfile();
      if (profile != null) {
        _addOutput(
          'Profile loaded: ${profile.displayName ?? profile.email ?? 'Unknown'}',
        );
        _addOutput('UID: ${profile.uid}');
        _addOutput('Email verified: ${profile.emailVerified}');
      } else {
        _addOutput('No profile data received');
      }
    } catch (e) {
      _addOutput('Get profile error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testSearchMusic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing search endpoint with new typed models...');
      final result = await _searchApiService.searchMusic(
        query: 'test',
        page: 1,
        limit: 5,
      );
      _addOutput('Search successful with typed models!');
      _addOutput('Query: ${result.query}');
      _addOutput('Total results: ${result.totalResults}');
      _addOutput('Execution time: ${result.executionTimeMs}ms');
      _addOutput('Found ${result.songs.length} songs');
      _addOutput('Found ${result.artists.length} artists');
      _addOutput('Found ${result.albums.length} albums');
    } catch (e) {
      _addOutput('Search error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testHomeEndpoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing home endpoints with new typed models...');

      // Test single optimized endpoint (1 API call)
      _addOutput('--- Testing Single Endpoint (Optimized) ---');
      final stopwatchSingle = Stopwatch()..start();

      final homeData = await _homeApiService.getHomeScreenData();
      stopwatchSingle.stop();

      _addOutput(
        '✅ Single endpoint response time: ${stopwatchSingle.elapsedMilliseconds}ms',
      );
      _addOutput('Greeting: ${homeData.greetingMessage}');
      _addOutput('User: ${homeData.userDisplayName}');
      _addOutput(
        'Continue listening: ${homeData.continueListening.length} items',
      );
      _addOutput('Top mixes: ${homeData.topMixes.length} items');
      _addOutput('Recent listening: ${homeData.recentListening.length} items');
      _addOutput(
        'User stats - Songs: ${homeData.userStats.totalSongs}, Artists: ${homeData.userStats.totalArtists}',
      );

      _addOutput('');
      _addOutput('--- Testing Individual Endpoints (Typed Models) ---');
      final stopwatchMultiple = Stopwatch()..start();

      // Test individual endpoints for comparison
      final continueListening = await _homeApiService.getContinueListening();
      _addOutput('Continue listening: ${continueListening.items.length} items');

      final topMixes = await _homeApiService.getTopMixes();
      _addOutput('Top mixes: ${topMixes.items.length} items');

      final recentListening = await _homeApiService.getRecentListening();
      _addOutput('Recent listening: ${recentListening.items.length} items');

      final userStats = await _homeApiService.getUserStats();
      _addOutput(
        'User stats - Songs: ${userStats.totalSongs}, Artists: ${userStats.totalArtists}',
      );

      stopwatchMultiple.stop();
      _addOutput(
        '⚠️  Multiple endpoints response time: ${stopwatchMultiple.elapsedMilliseconds}ms',
      );

      final improvement =
          ((stopwatchMultiple.elapsedMilliseconds -
                      stopwatchSingle.elapsedMilliseconds) /
                  stopwatchMultiple.elapsedMilliseconds *
                  100)
              .round();
      _addOutput(
        '🚀 Performance improvement: $improvement% faster with single endpoint',
      );
      ((stopwatchMultiple.elapsedMilliseconds -
                  stopwatchSingle.elapsedMilliseconds) /
              stopwatchMultiple.elapsedMilliseconds *
              100)
          .round();
      _addOutput(
        '🚀 Performance improvement: $improvement% faster with single endpoint',
      );
    } catch (e) {
      _addOutput('Home endpoints error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  Future<void> _testSongEndpoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing song endpoints with new typed models...');

      // Test get songs
      final songs = await _songApiService.getSongs(limit: 5);
      _addOutput('Get songs successful: ${songs.length} songs found');

      if (songs.isNotEmpty) {
        _addOutput(
          'First song: ${songs.first.title} by ${songs.first.artistNames.join(', ')}',
        );
      }
    } catch (e) {
      _addOutput('Song endpoints error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testPlaylistEndpoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing playlist endpoints with new typed models...');

      // Test get playlists
      final playlists = await _playlistApiService.getPlaylists();
      _addOutput(
        'Get playlists successful: ${playlists.playlists.length} playlists found (Total: ${playlists.total})',
      );

      // Test create a test playlist
      try {
        final newPlaylist = await _playlistApiService.createPlaylist(
          name: 'Test Playlist ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Created by API test',
        );
        _addOutput('Create playlist successful: ${newPlaylist.name}');

        // Test delete the playlist we just created
        await _playlistApiService.deletePlaylist(newPlaylist.id);
        _addOutput('Delete playlist successful');
      } catch (e) {
        _addOutput('Create/Delete playlist error: $e');
      }
    } catch (e) {
      _addOutput('Playlist endpoints error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testUserEndpoints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addOutput('Testing user endpoints with new typed models...');

      // Test get user stats
      final stats = await _userRepository.getUserStats();
      if (stats != null) {
        _addOutput(
          'Get user stats successful - Songs: ${stats.totalSongs}, Artists: ${stats.totalArtists}',
        );
      } else {
        _addOutput('Get user stats returned null');
      }

      // Test get favorite songs
      final favorites = await _userRepository.getFavoriteSongs();
      if (favorites != null) {
        _addOutput(
          'Get favorite songs successful: ${favorites.length} favorites',
        );
      } else {
        _addOutput('Get favorite songs returned null');
      }

      // Test get listening history
      final history = await _userRepository.getListeningHistory();
      if (history != null) {
        _addOutput('Get listening history successful: ${history.length} items');
      } else {
        _addOutput('Get listening history returned null');
      }
    } catch (e) {
      _addOutput('User endpoints error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearOutput,
            tooltip: 'Clear output',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testHealthCheck,
                  icon: const Icon(Icons.health_and_safety),
                  label: const Text('Health Check'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testProtectedEndpoint,
                  icon: const Icon(Icons.security),
                  label: const Text('Protected Endpoint'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetUserProfile,
                  icon: const Icon(Icons.person),
                  label: const Text('Get Profile'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSearchMusic,
                  icon: const Icon(Icons.search),
                  label: const Text('Test Search'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testHomeEndpoints,
                  icon: const Icon(Icons.home),
                  label: const Text('Test Home'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSongEndpoints,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Test Songs'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testPlaylistEndpoints,
                  icon: const Icon(Icons.playlist_play),
                  label: const Text('Test Playlists'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testUserEndpoints,
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Test User'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // API Configuration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Configuration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Base URL: ${ApiConfig.baseUrl}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Timeout: ${ApiConfig.timeout.inSeconds}s',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading) const LinearProgressIndicator(),

            const SizedBox(height: 8),

            // Output section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isEmpty
                        ? 'No output yet. Try testing an endpoint!'
                        : _output,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Make sure your FastAPI server is running\n'
                    '2. Update the base URL in ApiConfig if needed\n'
                    '3. Test Health Check first (no auth required)\n'
                    '4. Test Protected Endpoint (requires authentication)\n'
                    '5. Test Get Profile (requires authentication)\n'
                    '6. Test Search (requires authentication)\n'
                    '7. Test Home (requires authentication)',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
