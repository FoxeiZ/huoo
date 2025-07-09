import 'package:flutter/material.dart';
import 'package:huoo/screens/folder_selection_screen.dart';
import 'package:huoo/helpers/database/helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _totalSongs = 0;
  int _totalAlbums = 0;
  int _totalArtists = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final songs = await DatabaseHelper().songProvider.getAll();
      final albums = await DatabaseHelper().albumProvider.getAll();
      final artists = await DatabaseHelper().artistProvider.getAll();

      if (mounted) {
        setState(() {
          _totalSongs = songs.length;
          _totalAlbums = albums.length;
          _totalArtists = artists.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Music Library Section
              _buildSectionHeader('Music Library'),
              const SizedBox(height: 12),

              // Library Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Songs', _totalSongs, Icons.music_note),
                    const Divider(color: Colors.white24, height: 24),
                    _buildStatRow('Albums', _totalAlbums, Icons.album),
                    const Divider(color: Colors.white24, height: 24),
                    _buildStatRow('Artists', _totalArtists, Icons.person),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Manage Folders Button
              _buildSettingsItem(
                icon: Icons.folder,
                title: 'Manage Music Folders',
                subtitle: 'Add or remove music folders',
                onTap: () => _navigateToFolderManagement(),
              ),

              const SizedBox(height: 8),

              // Rescan Library Button
              _buildSettingsItem(
                icon: Icons.refresh,
                title: 'Rescan Library',
                subtitle: 'Scan for new music in existing folders',
                onTap: () => _rescanLibrary(),
              ),

              const SizedBox(height: 24),

              // App Settings Section
              _buildSectionHeader('App Settings'),
              const SizedBox(height: 12),

              _buildSettingsItem(
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'Customize app appearance',
                onTap: () => _showThemeOptions(),
              ),

              const SizedBox(height: 8),

              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () => _showNotificationSettings(),
              ),

              const SizedBox(height: 8),

              _buildSettingsItem(
                icon: Icons.storage,
                title: 'Storage',
                subtitle: 'Manage app data and cache',
                onTap: () => _showStorageSettings(),
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About'),
              const SizedBox(height: 12),

              _buildSettingsItem(
                icon: Icons.info,
                title: 'About Huoo',
                subtitle: 'Version, licenses, and more',
                onTap: () => _showAboutDialog(),
              ),

              const SizedBox(height: 8),

              _buildSettingsItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and support',
                onTap: () => _showHelpAndSupport(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatRow(String label, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1DB954), size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const Spacer(),
        Text(
          _isLoading ? '...' : count.toString(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1DB954), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }

  void _navigateToFolderManagement() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => const FolderSelectionScreen(isFromSettings: true),
          ),
        )
        .then((_) {
          // Refresh stats when returning from folder management
          _loadStats();
        });
  }

  void _rescanLibrary() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Rescan Library',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This will scan all your music folders for new songs. This may take a while.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement rescan functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rescan functionality coming soon!'),
                      backgroundColor: Color(0xFF1DB954),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                ),
                child: const Text('Rescan'),
              ),
            ],
          ),
    );
  }

  void _showThemeOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme customization coming soon!'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings coming soon!'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  void _showStorageSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage management coming soon!'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'About Huoo',
              style: TextStyle(color: Colors.white),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Huoo Music Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Version 1.0.0', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 16),
                Text(
                  'A modern music player built with Flutter for managing and playing your local music collection.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpAndSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support coming soon!'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }
}
