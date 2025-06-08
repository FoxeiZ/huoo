import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
              const Color(0xFF7BEEFF).withAlpha(10), // 0.04 opacity
              Colors.grey.shade900.withAlpha(128), // 0.5 opacity
            ],
            stops: [0.0, 0.25, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromRGBO(134, 200, 194, 1),
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome back !",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Continue Listening Section
                      const Text(
                        "Continue Listening",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Continue Listening Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildContinueListeningItem(
                            "Coffee & Jazz",
                            Colors.brown,
                          ),
                          _buildContinueListeningItem(
                            "My Playlist",
                            Colors.green,
                            isReleased: true,
                          ),
                          _buildContinueListeningItem(
                            "Anything Goes",
                            Colors.orange,
                          ),
                          _buildContinueListeningItem(
                            "Anime OSTs",
                            Colors.purple,
                          ),
                          _buildContinueListeningItem(
                            "Harry's House",
                            Colors.pink,
                          ),
                          _buildContinueListeningItem(
                            "Lo-fi Beats",
                            Colors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Your Top Mixes Section
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
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildTopMixItem("Pop Mix", Colors.red),
                            const SizedBox(width: 12),
                            _buildTopMixItem("Chill Mix", Colors.blue),
                            const SizedBox(width: 12),
                            _buildTopMixItem("Rock Mix", Colors.green),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Based on recent listening
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
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildRecentItem(Colors.orange),
                            const SizedBox(width: 12),
                            _buildRecentItem(Colors.purple),
                            const SizedBox(width: 12),
                            _buildRecentItem(Colors.teal),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Bottom padding for navigation
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

  Widget _buildContinueListeningItem(
    String title,
    Color color, {
    bool isReleased = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(102), // 0.4 opacity
        borderRadius: BorderRadius.circular(8),
      ),
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
                  ),
                  if (isReleased)
                    const Text(
                      "RELEASED",
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
    );
  }

  Widget _buildTopMixItem(String title, Color accentColor) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(Color color) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: color.withAlpha(77), // 0.3 opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.album, color: Colors.white54, size: 40)),
    );
  }
}
