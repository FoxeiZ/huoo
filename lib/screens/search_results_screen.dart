import 'package:flutter/material.dart';
import 'package:huoo/services/search_api_service.dart';
import 'package:huoo/models/api/api_models.dart';
import 'package:huoo/widgets/search/search_results_widget.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({required this.initialQuery, super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final SearchApiService _searchApiService = SearchApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SongSearchResult> _songs = [];
  List<ArtistSearchResult> _artists = [];
  List<AlbumSearchResult> _albums = [];
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
      final response = await _searchApiService.searchMusic(
        query: _searchController.text.trim(),
        page: _currentPage,
        limit: 20,
        searchType: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        if (reset) {
          _songs = response.songs;
          _artists = response.artists;
          _albums = response.albums;
        } else {
          _songs.addAll(response.songs);
          _artists.addAll(response.artists);
          _albums.addAll(response.albums);
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

        // Provide more user-friendly error messages
        if (e.toString().contains('500')) {
          _errorMessage =
              'The search service is currently experiencing issues. Please try again later.';
        } else if (e.toString().contains('timeout')) {
          _errorMessage =
              'Search request timed out. Please check your connection and try again.';
        } else if (e.toString().contains('not subscriptable')) {
          _errorMessage =
              'There\'s a temporary issue with the search service. Please try a different search term or try again later.';
        } else {
          _errorMessage = 'Unable to perform search. Please try again.';
        }
      });

      // Log the full error for debugging
      print('Search error: $e');
    }
  }

  Future<void> _performFallbackSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    // Try searching with just songs filter as fallback
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _selectedFilter = 'songs';
      });

      final response = await _searchApiService.searchMusic(
        query: _searchController.text.trim(),
        page: 1,
        limit: 10, // Reduced limit for better reliability
        searchType: 'songs',
      );

      setState(() {
        _songs = response.songs;
        _artists = []; // Clear others for fallback
        _albums = [];
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      // If even the fallback fails, show the error
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Search service is currently unavailable. Please try again later.';
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
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildResultsBody() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Search Unavailable',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'songs';
                      });
                      _performSearch();
                    },
                    child: const Text('Search songs only'),
                  ),
                  TextButton(
                    onPressed: _performFallbackSearch,
                    child: const Text('Try simple search'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate back to browse popular content instead
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: const Text('Browse Popular Instead'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tip: Try simpler search terms or check your internet connection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SearchResultsWidget(
      songs: _songs,
      artists: _artists,
      albums: _albums,
      selectedFilter: _selectedFilter,
      isLoading: _isLoading,
      onLoadMore: _loadMoreResults,
    );
  }
}
