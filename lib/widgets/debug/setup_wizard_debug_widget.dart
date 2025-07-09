import 'package:flutter/material.dart';
import 'package:huoo/services/setup_wizard_manager.dart';
import 'package:huoo/screens/welcome_screen.dart';

/// Debug widget for testing setup wizard functionality
class SetupWizardDebugWidget extends StatefulWidget {
  const SetupWizardDebugWidget({super.key});

  @override
  State<SetupWizardDebugWidget> createState() => _SetupWizardDebugWidgetState();
}

class _SetupWizardDebugWidgetState extends State<SetupWizardDebugWidget> {
  Map<String, dynamic>? _setupStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSetupStatus();
  }

  Future<void> _loadSetupStatus() async {
    setState(() {
      _isLoading = true;
    });

    final status = await SetupWizardManager.getSetupStatus();
    
    setState(() {
      _setupStatus = status;
      _isLoading = false;
    });
  }

  Future<void> _resetSetup() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Setup Wizard?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will reset all setup progress and show the welcome screen on next app launch.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              await SetupWizardManager.resetSetup();
              _loadSetupStatus();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Setup wizard has been reset'),
                    backgroundColor: Color(0xFF1DB954),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSetupWizard() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Color(0xFF1DB954)),
                const SizedBox(width: 8),
                const Text(
                  'Setup Wizard Debug',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadSetupStatus,
                  icon: const Icon(Icons.refresh, color: Colors.white54),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              )
            else if (_setupStatus != null) ...[
              _buildStatusRow('First Launch', _setupStatus!['isFirstLaunch']),
              _buildStatusRow('Setup Completed', _setupStatus!['isSetupCompleted']),
              _buildStatusRow('Current Step', _setupStatus!['currentStep']),
              _buildStatusRow('Welcome Done', _setupStatus!['welcomeCompleted']),
              _buildStatusRow('Sign In Done', _setupStatus!['signInCompleted']),
              _buildStatusRow('Permissions Done', _setupStatus!['permissionsCompleted']),
              _buildStatusRow('Folders Done', _setupStatus!['foldersCompleted']),
              _buildStatusRow('Progress', '${(_setupStatus!['setupProgress'] * 100).toStringAsFixed(0)}%'),
              
              if (_setupStatus!['setupCompletedDate'] != null)
                _buildStatusRow('Completed On', _setupStatus!['setupCompletedDate'].toString().split('T')[0]),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetSetup,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset Setup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startSetupWizard,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Setup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: value is bool 
                  ? (value ? Colors.green : Colors.red)
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
