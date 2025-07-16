import 'package:flutter/material.dart';
import 'package:huoo/repositories/user_repository.dart';
import 'package:huoo/services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final UserRepository _userRepository = UserRepository();
  final ApiService _apiService = ApiService();

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
      final result = await _apiService.testProtectedEndpoint();
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
      _addOutput('Testing search endpoint...');
      final result = await _apiService.searchMusic(
        query: 'test',
        page: 1,
        limit: 5,
      );
      _addOutput('Search successful: ${result.keys.join(', ')}');

      if (result['songs'] != null) {
        _addOutput('Found ${result['songs'].length} songs');
      }
      if (result['artists'] != null) {
        _addOutput('Found ${result['artists'].length} artists');
      }
      if (result['albums'] != null) {
        _addOutput('Found ${result['albums'].length} albums');
      }
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
      _addOutput('Testing home endpoints...');

      // Test single optimized endpoint (1 API call)
      _addOutput('--- Testing Single Endpoint (Optimized) ---');
      final stopwatchSingle = Stopwatch()..start();

      final homeData = await _apiService.getHomeScreenData();
      stopwatchSingle.stop();

      _addOutput(
        '✅ Single endpoint response time: ${stopwatchSingle.elapsedMilliseconds}ms',
      );
      _addOutput('Greeting: ${homeData['greeting_message']}');
      _addOutput('User: ${homeData['user_display_name']}');
      _addOutput(
        'Continue listening: ${(homeData['continue_listening'] as List).length} items',
      );
      _addOutput('Top mixes: ${(homeData['top_mixes'] as List).length} items');
      _addOutput(
        'Recent listening: ${(homeData['recent_listening'] as List).length} items',
      );
      _addOutput(
        'User stats - Songs: ${homeData['user_stats']['total_songs']}, Artists: ${homeData['user_stats']['total_artists']}',
      );

      _addOutput('');
      _addOutput('--- Testing Individual Endpoints (Legacy) ---');
      final stopwatchMultiple = Stopwatch()..start();

      // Test individual endpoints for comparison
      final continueListening = await _apiService.getContinueListening();
      _addOutput('Continue listening: ${continueListening.length} items');

      final topMixes = await _apiService.getTopMixes();
      _addOutput('Top mixes: ${topMixes.length} items');

      final recentListening = await _apiService.getRecentListening();
      _addOutput('Recent listening: ${recentListening.length} items');

      final userStats = await _apiService.getUserStats();
      _addOutput(
        'User stats - Songs: ${userStats['total_songs']}, Artists: ${userStats['total_artists']}',
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
        '🚀 Performance improvement: ${improvement}% faster with single endpoint',
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
                  onPressed: _isLoading ? null : _testHomeEndpoints,
                  icon: const Icon(Icons.home),
                  label: const Text('Test Home API'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // API Configuration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
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
