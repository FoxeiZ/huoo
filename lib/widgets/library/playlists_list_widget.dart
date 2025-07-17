import 'package:flutter/material.dart';
import 'package:huoo/models/playlist.dart';
import 'package:huoo/services/playlist_api_service.dart';

class PlaylistsListWidget extends StatefulWidget {
  const PlaylistsListWidget({super.key});

  @override
  State<PlaylistsListWidget> createState() => _PlaylistsListWidgetState();
}

class _PlaylistsListWidgetState extends State<PlaylistsListWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PlaylistApiService _playlistService = PlaylistApiService();

  List<Playlist> _localPlaylists = [];
  List<Playlist> _onlinePlaylists = [];
  bool _isLoading = true;
  bool _isLoadingOnline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeService();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    // The PlaylistApiService doesn't need initialization
  }

  Future<void> _loadPlaylists() async {
    setState(() => _isLoading = true);

    try {
      // Load online playlists from API
      final playlists = await _playlistService.getPlaylists();

      setState(() {
        _localPlaylists = []; // Local playlists not implemented yet
        _onlinePlaylists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load playlists: $e')));
      }
    }
  }

  Future<void> _syncOnlinePlaylists() async {
    setState(() => _isLoadingOnline = true);

    try {
      final playlists = await _playlistService.getPlaylists();
      setState(() {
        _onlinePlaylists = playlists;
        _isLoadingOnline = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Online playlists synced successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoadingOnline = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync online playlists: $e')),
        );
      }
    }
  }

  Future<void> _createPlaylist(PlaylistType type) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'Create ${type == PlaylistType.local ? 'Local' : 'Online'} Playlist',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final description =
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim();

        if (type == PlaylistType.online) {
          await _playlistService.createPlaylist(
            name: nameController.text.trim(),
            description: description,
          );

          _loadPlaylists();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Playlist created successfully')),
            );
          }
        } else {
          // Local playlists not implemented yet
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Local playlists not implemented yet'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create playlist: $e')),
          );
        }
      }
    }
  }

  Widget _buildPlaylistList(List<Playlist> playlists, PlaylistType type) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == PlaylistType.local ? 'Local' : 'Online'} Playlists',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == PlaylistType.local
                  ? 'Create your first local playlist'
                  : 'Sync or create online playlists',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createPlaylist(type),
              icon: const Icon(Icons.add),
              label: Text(
                'Create ${type == PlaylistType.local ? 'Local' : 'Online'} Playlist',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          type == PlaylistType.online ? _syncOnlinePlaylists : _loadPlaylists,
      child: ListView.builder(
        itemCount: playlists.length + 1, // +1 for the create button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Create playlist button at the top
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _createPlaylist(type),
                icon: const Icon(Icons.add),
                label: Text(
                  'Create ${type == PlaylistType.local ? 'Local' : 'Online'} Playlist',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            );
          }

          final playlist = playlists[index - 1];
          return PlaylistTile(
            playlist: playlist,
            onTap: () => _openPlaylist(playlist),
            onDelete: () => _deletePlaylist(playlist),
          );
        },
      ),
    );
  }

  void _openPlaylist(Playlist playlist) {
    // TODO: Navigate to playlist detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening playlist: ${playlist.name}')),
    );
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Delete Playlist',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _playlistService.deletePlaylist(
          playlist.apiId ?? playlist.id.toString(),
        );
        _loadPlaylists();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete playlist: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF1E1E1E),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_android),
                    const SizedBox(width: 8),
                    const Text('Local'),
                    if (_isLoading) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud),
                    const SizedBox(width: 8),
                    const Text('Online'),
                    if (_isLoadingOnline) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaylistList(_localPlaylists, PlaylistType.local),
              _buildPlaylistList(_onlinePlaylists, PlaylistType.online),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF2A2A2A),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color:
                playlist.type == PlaylistType.local
                    ? Colors.blue
                    : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            playlist.type == PlaylistType.local
                ? Icons.phone_android
                : Icons.cloud,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (playlist.description != null)
              Text(
                playlist.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '${playlist.type == PlaylistType.local ? 'Local' : 'Online'} • Created ${_formatDate(playlist.createdAt)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: const Color(0xFF3A3A3A),
          onSelected: (value) {
            switch (value) {
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: onTap,
      ),
    );
  }
}
