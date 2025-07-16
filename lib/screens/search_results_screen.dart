import 'package:flutter/material.dart';
import 'package:huoo/services/api_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({required this.initialQuery, super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _songs = [];
  List<dynamic> _artists = [];
  List<dynamic> _albums = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedFilter = 'all';
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _performSearch();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _performSearch({bool reset = true}) async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      if (reset) {
        _songs.clear();
        _artists.clear();
        _albums.clear();
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    try {
      final response = await _apiService.searchMusic(
        query: _searchController.text.trim(),
        page: _currentPage,
        limit: 20,
        searchType: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        if (response['songs'] != null) {
          if (reset) {
            _songs = response['songs'];
          } else {
            _songs.addAll(response['songs']);
          }
        }

        if (response['artists'] != null) {
          if (reset) {
            _artists = response['artists'];
          } else {
            _artists.addAll(response['artists']);
          }
        }

        if (response['albums'] != null) {
          if (reset) {
            _albums = response['albums'];
          } else {
            _albums.addAll(response['albums']);
          }
        }

        // Check if we have more data
        final totalResults = (_songs.length + _artists.length + _albums.length);
        _hasMoreData = totalResults >= _currentPage * 20;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreResults() async {
    setState(() {
      _currentPage++;
    });
    await _performSearch(reset: false);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for songs, artists, albums...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _songs.clear();
                      _artists.clear();
                      _albums.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('songs', 'Songs'),
                  const SizedBox(width: 8),
                  _buildFilterChip('artists', 'Artists'),
                  const SizedBox(width: 8),
                  _buildFilterChip('albums', 'Albums'),
                ],
              ),
            ),
          ),

          // Results
          Expanded(child: _buildResultsBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _performSearch,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading && _songs.isEmpty && _artists.isEmpty && _albums.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Search failed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_songs.isEmpty && _artists.isEmpty && _albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Songs section
        if (_songs.isNotEmpty &&
            (_selectedFilter == 'all' || _selectedFilter == 'songs')) ...[
          _buildSectionHeader('Songs', _songs.length),
          const SizedBox(height: 8),
          ..._songs.map((song) => _buildSongTile(song)).toList(),
          const SizedBox(height: 24),
        ],

        // Artists section
        if (_artists.isNotEmpty &&
            (_selectedFilter == 'all' || _selectedFilter == 'artists')) ...[
          _buildSectionHeader('Artists', _artists.length),
          const SizedBox(height: 8),
          ..._artists.map((artist) => _buildArtistTile(artist)).toList(),
          const SizedBox(height: 24),
        ],

        // Albums section
        if (_albums.isNotEmpty &&
            (_selectedFilter == 'all' || _selectedFilter == 'albums')) ...[
          _buildSectionHeader('Albums', _albums.length),
          const SizedBox(height: 8),
          ..._albums.map((album) => _buildAlbumTile(album)).toList(),
          const SizedBox(height: 24),
        ],

        // Loading indicator for pagination
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongTile(dynamic song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.2),
          child: Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          song['title'] ?? 'Unknown Title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${song['artist'] ?? 'Unknown Artist'} • ${song['album'] ?? 'Unknown Album'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (song['duration'] != null)
              Text(
                _formatDuration(song['duration']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(width: 8),
            Icon(Icons.play_arrow),
          ],
        ),
        onTap: () {
          // TODO: Play song
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Playing: ${song['title']}')));
        },
      ),
    );
  }

  Widget _buildArtistTile(dynamic artist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(
          artist['name'] ?? 'Unknown Artist',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${artist['song_count'] ?? 0} songs'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to artist page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View artist: ${artist['name']}')),
          );
        },
      ),
    );
  }

  Widget _buildAlbumTile(dynamic album) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.album,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        title: Text(
          album['title'] ?? 'Unknown Album',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${album['artist'] ?? 'Unknown Artist'} • ${album['year'] ?? 'Unknown Year'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to album page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View album: ${album['title']}')),
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
