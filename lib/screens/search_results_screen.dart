import 'package:flutter/material.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/widgets/search/search_results_widget.dart';

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
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildResultsBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
