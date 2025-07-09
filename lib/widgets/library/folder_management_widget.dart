import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:huoo/services/media_scanner.dart';
import 'package:huoo/helpers/database/types.dart';

class FolderManagementWidget extends StatefulWidget {
  const FolderManagementWidget({super.key});

  @override
  State<FolderManagementWidget> createState() => _FolderManagementWidgetState();
}

class _FolderManagementWidgetState extends State<FolderManagementWidget> {
  final MediaScannerService _scanner = MediaScannerService();
  final List<String> _selectedFolders = [];

  bool _isScanning = false;
  double _progress = 0.0;
  String _statusMessage = '';
  BulkImportResult? _lastResult;

  @override
  void dispose() {
    _scanner.cancelScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Folder Button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Music Folders (${_selectedFolders.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _addFolder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Folder'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Folders List or Empty State
          Expanded(
            child:
                _selectedFolders.isEmpty
                    ? _buildEmptyFoldersState()
                    : Column(
                      children: [
                        // Folders List
                        Expanded(
                          child: ListView.builder(
                            itemCount: _selectedFolders.length,
                            itemBuilder: (context, index) {
                              final folder = _selectedFolders[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.folder,
                                    color: Color(0xFF1DB954),
                                  ),
                                  title: Text(
                                    folder.split('/').last,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    folder,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        _isScanning
                                            ? null
                                            : () => _removeFolder(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Scan Button
                        if (_selectedFolders.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isScanning ? null : _startScan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1DB954),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon:
                                  _isScanning
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(Icons.refresh),
                              label: Text(
                                _isScanning ? 'Scanning...' : 'Scan Music',
                              ),
                            ),
                          ),
                        ],

                        // Progress Indicator
                        if (_isScanning || _lastResult != null) ...[
                          const SizedBox(height: 16),
                          _buildScanProgress(),
                        ],
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFoldersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Music Folders Added',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add folders containing your music to get started',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addFolder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.folder_open),
            label: const Text('Add Your First Folder'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isScanning ? Icons.refresh : Icons.check_circle,
                color: _isScanning ? const Color(0xFF1DB954) : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                _isScanning ? 'Scanning...' : 'Scan Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isScanning) ...[
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade700,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DB954),
              ),
            ),
            const SizedBox(height: 8),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
          if (_lastResult != null && !_isScanning) ...[
            Text(
              'Found ${_lastResult!.successCount} songs',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Music Folder',
    );

    if (result != null && !_selectedFolders.contains(result)) {
      setState(() {
        _selectedFolders.add(result);
      });
    }
  }

  void _removeFolder(int index) {
    setState(() {
      _selectedFolders.removeAt(index);
    });
  }

  Future<void> _startScan() async {
    if (_selectedFolders.isEmpty) return;

    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _statusMessage = 'Starting scan...';
      _lastResult = null;
    });

    try {
      await for (final progress in _scanner.scanFoldersStream(
        _selectedFolders,
      )) {
        setState(() {
          _statusMessage = progress.message;
          _progress = progress.progressPercentage;
        });

        if (progress.isCompleted) {
          setState(() {
            _isScanning = false;
            _lastResult = progress.result;
          });

          if (progress.result != null) {
            _showCompletionSnackBar(progress.result!);
          }
          break;
        } else if (progress.isError) {
          setState(() {
            _isScanning = false;
          });

          _showErrorSnackBar(progress.error ?? 'Unknown error');
          break;
        }
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });

      _showErrorSnackBar(e.toString());
    }
  }

  void _showCompletionSnackBar(BulkImportResult result) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported ${result.successCount} songs!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
