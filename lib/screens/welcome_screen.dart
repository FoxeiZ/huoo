import 'package:flutter/material.dart';
import 'package:huoo/screens/sign_in_screen.dart';
import 'package:huoo/services/setup_wizard_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: isSmallScreen ? 100 : 120,
                  height: isSmallScreen ? 100 : 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.music_note,
                    size: isSmallScreen ? 50 : 60,
                    color: Colors.deepPurple,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 30),

                // App Name
                Text(
                  'Huoo Music',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'Your Personal Music Experience',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isSmallScreen ? 30 : 40),

                // Features List
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'What\'s New',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          Icons.folder_outlined,
                          'Manual Folder Selection',
                          'Choose specific folders to scan for music',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.search,
                          'Smart Music Discovery',
                          'Automatic metadata extraction and cover art detection',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.speed,
                          'Fast & Efficient',
                          'Optimized scanning with real-time progress tracking',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.library_music,
                          'Rich Library Management',
                          'Organized by artists, albums, and playlists',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark welcome step as completed
                      await SetupWizardManager.markStepCompleted(
                        SetupStep.welcome,
                      );
                      await SetupWizardManager.setCurrentStep(SetupStep.signIn);

                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Version info
                Text(
                  'Version 2.0.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
