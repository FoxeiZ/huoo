import 'package:flutter/material.dart';



class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  LibraryTabState createState() => LibraryTabState();
}

class LibraryTabState extends State<LibraryTab>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                      color: const Color(0xFF1DB954),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Colors.white, size: 24),
                ],
              ),
            ),

            // Category TabBar with custom button styling
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: [
                    const SizedBox(width: 16), // Left padding
                    ...categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      String category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                          },
                          child: AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, child) {
                              bool isSelected = _tabController.index == index;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8), // Right padding
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content based on selected tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const Center(child: Text('Folders', style: TextStyle(color: Colors.white))),
                  const Center(child: Text('Playlists', style: TextStyle(color: Colors.white))),
                  const Center(child: Text('Artists', style: TextStyle(color: Colors.white))),
                  const Center(child: Text('Albums', style: TextStyle(color: Colors.white))),
                  const Center(child: Text('Podcasts', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
