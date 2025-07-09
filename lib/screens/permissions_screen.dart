import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:huoo/screens/folder_selection_screen.dart';
import 'package:huoo/services/setup_wizard_manager.dart';

enum AppPermissionStatus { granted, denied, checking }

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _storageGranted = false;
  bool _isCheckingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      // Check storage permissions based on Android version
      bool hasPermission = false;

      // For Android 13+ (API 33+), we need audio permission
      final audioStatus = await Permission.audio.status;
      final storageStatus = await Permission.storage.status;

      // Check if we have either audio permission (Android 13+) or storage permission
      hasPermission =
          audioStatus == PermissionStatus.granted ||
          storageStatus == PermissionStatus.granted;

      setState(() {
        _isCheckingPermissions = false;
        _storageGranted = hasPermission;
      });
    } catch (e) {
      setState(() {
        _isCheckingPermissions = false;
        _storageGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Permissions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Setup Required Permissions',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'To provide the best music experience, Huoo needs access to your music folders.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Permission Cards
            _buildPermissionCard(
              icon: Icons.folder_open,
              title: 'Folder Access',
              description: 'Access to read music files from selected folders',
              status:
                  _isCheckingPermissions
                      ? AppPermissionStatus.checking
                      : (_storageGranted
                          ? AppPermissionStatus.granted
                          : AppPermissionStatus.denied),
              onTap: _storageGranted ? null : _requestFolderAccess,
            ),

            const SizedBox(height: 16),

            _buildPermissionCard(
              icon: Icons.music_note,
              title: 'Audio File Reading',
              description: 'Read metadata and artwork from audio files',
              status:
                  _isCheckingPermissions
                      ? AppPermissionStatus.checking
                      : (_storageGranted
                          ? AppPermissionStatus.granted
                          : AppPermissionStatus.denied),
              onTap: null, // This is handled automatically with folder access
            ),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy & Security',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your music files remain on your device\n'
                      '• No data is uploaded to external servers\n'
                      '• Only selected folders are accessed\n'
                      '• You can change folder access anytime',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _storageGranted && !_isCheckingPermissions
                        ? () async {
                          // Store context reference before async operations
                          final navigator = Navigator.of(context);

                          // Mark permissions step as completed
                          await SetupWizardManager.markStepCompleted(
                            SetupStep.permissions,
                          );
                          await SetupWizardManager.setCurrentStep(
                            SetupStep.folders,
                          );

                          if (mounted) {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) => const FolderSelectionScreen(),
                              ),
                            );
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    _isCheckingPermissions
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Checking Permissions...'),
                          ],
                        )
                        : const Text(
                          'Continue to Folder Selection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Skip for now option
            TextButton(
              onPressed: () async {
                // Store context reference before async operations
                final navigator = Navigator.of(context);

                // Mark permissions as completed even if skipped
                await SetupWizardManager.markStepCompleted(
                  SetupStep.permissions,
                );
                await SetupWizardManager.setCurrentStep(SetupStep.folders);

                if (mounted) {
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const FolderSelectionScreen(),
                    ),
                  );
                }
              },
              child: Text(
                'Skip for now',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required AppPermissionStatus status,
    VoidCallback? onTap,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case AppPermissionStatus.granted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Granted';
        break;
      case AppPermissionStatus.denied:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Tap to Grant';
        break;
      case AppPermissionStatus.checking:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Checking...';
        break;
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestFolderAccess() async {
    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      // Request appropriate permissions based on Android version
      final storageStatus = await Permission.storage.request();
      final audioStatus = await Permission.audio.request();

      // Check if we got at least one permission
      bool hasPermission =
          storageStatus == PermissionStatus.granted ||
          audioStatus == PermissionStatus.granted;

      setState(() {
        _isCheckingPermissions = false;
        _storageGranted = hasPermission;
      });

      // If permission was denied, show instructions
      if (!hasPermission) {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() {
        _isCheckingPermissions = false;
        _storageGranted = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Storage permission is required to access your music files. '
              'Please grant the permission in the next dialog or go to app settings to enable it manually.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }
}
