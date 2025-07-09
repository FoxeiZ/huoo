import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:huoo/services/media_scanner.dart';
import 'package:huoo/helpers/database/types.dart';
import 'package:huoo/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderSelectionScreen extends StatefulWidget {
  final bool isFromSettings;

  const FolderSelectionScreen({super.key, this.isFromSettings = false});

  @override
  State<FolderSelectionScreen> createState() => _FolderSelectionScreenState();
}

class _FolderSelectionScreenState extends State<FolderSelectionScreen> {
  final MediaScannerService _scanner = MediaScannerService();
  final List<String> _selectedFolders = [];

  bool _isScanning = false;
  double _progress = 0.0;
  String _statusMessage = 'Ready to scan';
  String _currentFile = '';
  BulkImportResult? _lastResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFromSettings
              ? 'Manage Music Folders'
              : 'Music Folder Scanner',
        ),
        backgroundColor:
            widget.isFromSettings
                ? const Color(0xFF121212)
                : Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: widget.isFromSettings ? Colors.white : null,
        actions: [
          if (!widget.isFromSettings)
            TextButton(
              onPressed: _isScanning ? null : _skipSetup,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: _isScanning ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: widget.isFromSettings ? const Color(0xFF121212) : null,
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color:
                          widget.isFromSettings
                              ? const Color(0xFF1DB954)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading saved folders...',
                      style: TextStyle(
                        color: widget.isFromSettings ? Colors.white70 : null,
                      ),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Card(
                      color:
                          widget.isFromSettings
                              ? const Color(0xFF2A2A2A)
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Music Folders',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color:
                                    widget.isFromSettings ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose folders containing your music files. The scanner will recursively search for supported audio formats.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    widget.isFromSettings
                                        ? Colors.white70
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Supported formats: MP3, WAV, FLAC, AAC, OGG, M4A, OPUS',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    widget.isFromSettings
                                        ? Colors.white60
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You can skip this step and set up your music library later in the settings.',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Folder selection section
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Selected Folders (${_selectedFolders.length})',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color:
                                  widget.isFromSettings ? Colors.white : null,
                            ),
                          ),
                        ),
                        if (_selectedFolders.isNotEmpty) ...[
                          TextButton(
                            onPressed: _isScanning ? null : _clearAllFolders,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: _isScanning ? Colors.grey : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isScanning ? null : _addFolder,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Add Folder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.isFromSettings
                                    ? const Color(0xFF1DB954)
                                    : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Selected folders list - Fixed height to prevent compression
                    Container(
                      height:
                          180, // Fixed height to prevent being pushed by progress
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              widget.isFromSettings
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            widget.isFromSettings
                                ? const Color(0xFF1A1A1A)
                                : null,
                      ),
                      child:
                          _selectedFolders.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_outlined,
                                      size: 48,
                                      color:
                                          widget.isFromSettings
                                              ? Colors.white24
                                              : Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No folders selected',
                                      style: TextStyle(
                                        color:
                                            widget.isFromSettings
                                                ? Colors.white60
                                                : Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Click "Add Folder" to select music directories',
                                      style: TextStyle(
                                        color:
                                            widget.isFromSettings
                                                ? Colors.white38
                                                : Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: _selectedFolders.length,
                                itemBuilder: (context, index) {
                                  final folder = _selectedFolders[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.folder,
                                      color:
                                          widget.isFromSettings
                                              ? const Color(0xFF1DB954)
                                              : Colors.blue,
                                    ),
                                    title: Text(
                                      folder,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            widget.isFromSettings
                                                ? Colors.white
                                                : null,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          _isScanning
                                              ? null
                                              : () => _removeFolder(index),
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Scan button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed:
                            _selectedFolders.isEmpty || _isScanning
                                ? null
                                : _startScan,
                        icon:
                            _isScanning
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.search),
                        label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Continue Later button - only show when not from settings
                    if (!widget.isFromSettings) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isScanning ? null : _skipSetup,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Continue Later'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Done button - only show when from settings and scan is complete
                    if (widget.isFromSettings && _lastResult != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check),
                          label: const Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],

                    // Progress section - make it more compact and scrollable if needed
                    if (_isScanning || _lastResult != null) ...[
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Card(
                            color:
                                widget.isFromSettings
                                    ? const Color(0xFF2A2A2A)
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                12.0,
                              ), // Reduced padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isScanning
                                            ? Icons.refresh
                                            : Icons.check_circle,
                                        color:
                                            _isScanning
                                                ? Colors.blue
                                                : Colors.green,
                                        size: 20, // Smaller icon
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isScanning
                                            ? 'Scanning...'
                                            : 'Scan Complete',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          color:
                                              widget.isFromSettings
                                                  ? Colors.white
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  if (_isScanning) ...[
                                    LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _statusMessage,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            widget.isFromSettings
                                                ? Colors.white70
                                                : null,
                                      ),
                                    ),
                                    if (_currentFile.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Current: $_currentFile',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color:
                                              widget.isFromSettings
                                                  ? Colors.white60
                                                  : null,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],

                                  if (_lastResult != null && !_isScanning) ...[
                                    Text(
                                      'Import Results:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        color:
                                            widget.isFromSettings
                                                ? Colors.white
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildCompactResultCard(
                                          'Success',
                                          _lastResult!.successCount,
                                          Colors.green,
                                          Icons.check_circle_outline,
                                        ),
                                        _buildCompactResultCard(
                                          'Failed',
                                          _lastResult!.failureCount,
                                          Colors.red,
                                          Icons.error_outline,
                                        ),
                                        _buildCompactResultCard(
                                          'Total',
                                          _lastResult!.successCount +
                                              _lastResult!.failureCount,
                                          Colors.blue,
                                          Icons.library_music,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Add some bottom spacing when no progress is shown
                      const Spacer(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildCompactResultCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.isFromSettings ? Colors.white : color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: widget.isFromSettings ? Colors.white70 : null,
          ),
        ),
      ],
    );
  }

  Future<void> _loadSavedFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFolders = prefs.getStringList('selected_music_folders') ?? [];

      if (mounted) {
        setState(() {
          _selectedFolders.clear();
          _selectedFolders.addAll(savedFolders);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved folders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_music_folders', _selectedFolders);

      // Show a brief confirmation (optional)
      if (mounted && widget.isFromSettings) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folders saved successfully'),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF1DB954),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving folders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save folders'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Music Folder',
    );

    if (result != null && !_selectedFolders.contains(result)) {
      setState(() {
        _selectedFolders.add(result);
      });
      await _saveFolders();
    }
  }

  void _removeFolder(int index) {
    setState(() {
      _selectedFolders.removeAt(index);
    });
    _saveFolders();
  }

  Future<void> _clearAllFolders() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                widget.isFromSettings ? const Color(0xFF2A2A2A) : null,
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Clear All Folders?',
                  style: TextStyle(
                    color: widget.isFromSettings ? Colors.white : null,
                  ),
                ),
              ],
            ),
            content: Text(
              'This will remove all selected folders. You can add them back later.',
              style: TextStyle(
                color: widget.isFromSettings ? Colors.white70 : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedFolders.clear();
                  });
                  _saveFolders();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }

  Future<void> _startScan() async {
    if (_selectedFolders.isEmpty) return;

    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _statusMessage = 'Starting scan...';
      _currentFile = '';
      _lastResult = null;
    });

    try {
      await for (final progress in _scanner.scanFoldersStream(
        _selectedFolders,
      )) {
        setState(() {
          _statusMessage = progress.message;
          _progress = progress.progressPercentage;
          _currentFile = progress.currentFile ?? '';
        });

        if (progress.isCompleted) {
          setState(() {
            _isScanning = false;
            _lastResult = progress.result;
          });

          if (progress.result != null) {
            _showCompletionDialog(progress.result!);
          }
          break;
        } else if (progress.isError) {
          setState(() {
            _isScanning = false;
          });

          _showErrorDialog(progress.error ?? 'Unknown error');
          break;
        }
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showCompletionDialog(BulkImportResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                widget.isFromSettings ? const Color(0xFF2A2A2A) : null,
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Scan Complete',
                  style: TextStyle(
                    color: widget.isFromSettings ? Colors.white : null,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Successfully imported: ${result.successCount} songs',
                  style: TextStyle(
                    color: widget.isFromSettings ? Colors.white : null,
                  ),
                ),
                if (result.failureCount > 0)
                  Text(
                    'Failed to import: ${result.failureCount} songs',
                    style: TextStyle(
                      color: widget.isFromSettings ? Colors.white : null,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Your music library has been updated!',
                  style: TextStyle(
                    color: widget.isFromSettings ? Colors.white : null,
                  ),
                ),
              ],
            ),
            actions: [
              if (widget.isFromSettings) ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Stay Here'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToMainApp();
                  },
                  child: const Text('Go to Music Player'),
                ),
              ],
            ],
          ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                widget.isFromSettings ? const Color(0xFF2A2A2A) : null,
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Scan Failed',
                  style: TextStyle(
                    color: widget.isFromSettings ? Colors.white : null,
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: TextStyle(
                color: widget.isFromSettings ? Colors.white70 : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _skipSetup() {
    if (widget.isFromSettings) {
      // If from settings, just go back
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('Skip Music Setup?'),
              ],
            ),
            content: const Text(
              'You can add music folders later in the app settings. Would you like to proceed to the main app?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToMainApp();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _navigateToMainApp() {
    // Navigate to main app using your friend's beautiful HomeScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _scanner.cancelScan();
    super.dispose();
  }
}
