import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromRGBO(134, 200, 194, 1).withAlpha(153), // 0.6 opacity
              const Color(0xFF7BEEFF).withAlpha(102), // 0.4 opacity
              Colors.grey.shade900.withAlpha(255), // Fully opaque
            ],
            stops: [0.0, 0.25, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Logo placeholder - replace with your app logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(134, 200, 194, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset('assets/huoo_logo.png'),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Songs, Artists, Podcasts & More",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Your Top Genres
                      const Text(
                        "Your Top Genres",
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
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildGenreItem("Kpop", Colors.green),
                          _buildGenreItem("Indie", Colors.pink),
                          _buildGenreItem("R&B", Colors.blue),
                          _buildGenreItem("Pop", Colors.orange),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Browse All
                      const Text(
                        "Browse All",
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
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildBrowseItem("Made for You", Colors.teal),
                          _buildBrowseItem(
                            "RELEASED",
                            Colors.purple,
                            hasLabel: true,
                          ),
                          _buildBrowseItem(
                            "Music Charts",
                            Colors.blue.shade800,
                          ),
                          _buildBrowseItem("Podcasts", Colors.red.shade800),
                          _buildBrowseItem("Bollywood", Colors.brown.shade700),
                          _buildBrowseItem("Pop Fusion", Colors.teal.shade700),
                        ],
                      ),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreItem(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51), // 0.2 opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.album,
                  color: Colors.white.withAlpha(204), // 0.8 opacity
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseItem(String title, Color color, {bool hasLabel = false}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasLabel)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (hasLabel) const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(51), // 0.2 opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Colors.white.withAlpha(204), // 0.8 opacity
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
