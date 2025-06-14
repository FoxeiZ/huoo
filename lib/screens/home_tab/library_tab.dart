import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Library',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        primaryColor: Color(0xFF1DB954),
      ),
      home: LibraryTab(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LibraryTab extends StatefulWidget {
  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = [
    'Folders',
    'Playlists',
    'Artists',
    'Albums',
    'Podcasts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: categories.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<PlaylistItem> playlists = [
    PlaylistItem(name: 'moods', playlistCount: 11),
    PlaylistItem(name: 'blends', playlistCount: 8),
    PlaylistItem(name: 'favs', playlistCount: 14),
    PlaylistItem(name: 'random?', playlistCount: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF1DB954),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Your Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.search, color: Colors.white, size: 24),
                ],
              ),
            ),

            // Category TabBar with custom button styling
            Container(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: ClampingScrollPhysics(), // Prevents over-scroll
                child: Row(
                  children: [
                    SizedBox(width: 16), // Left padding
                    ...categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      String category = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                          },
                          child: AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, child) {
                              bool isSelected = _tabController.index == index;
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Color(0xFF1DB954)
                                          : Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(width: 8), // Right padding
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Content based on selected tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Folders tab
                  _buildPlaylistContent(),
                  // Playlists tab (default content)
                  _buildPlaylistContent(),
                  // Artists tab
                  Center(
                    child: Text(
                      'Artists',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Albums tab
                  Center(
                    child: Text(
                      'Albums',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Podcasts tab
                  Center(
                    child: Text(
                      'Podcasts',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistContent() {
    return Column(
      children: [
        // Add New Playlist
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Text(
                'Add New Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Your Liked Songs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4C1A57), Color(0xFF9C4CB4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Text(
                'Your Liked Songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Recently played header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text(
                'Recently played',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Playlist items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.folder,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${playlist.playlistCount} playlists',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlaylistItem {
  final String name;
  final int playlistCount;

  PlaylistItem({required this.name, required this.playlistCount});
}
