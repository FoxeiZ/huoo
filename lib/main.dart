import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:logger/logger.dart';

import 'package:huoo/screens/welcome_screen.dart';
import 'package:huoo/screens/home_screen.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/services/setup_wizard_manager.dart';

final log = Logger(
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initialize();
  JustAudioMediaKit.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final AudioPlayerBloc _audioPlayerBloc = AudioPlayerBloc();

  const MyApp({super.key});

  Widget _buildApp(BuildContext context) {
    return BlocProvider.value(
      value: _audioPlayerBloc,
      child: MaterialApp(
        title: 'Huoo Music Player',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: const AppInitializer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildApp(context);
  }
}

/// Widget that determines the initial screen based on setup status
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _shouldShowSetup = false;

  @override
  void initState() {
    super.initState();
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    try {
      final shouldShow = await SetupWizardManager.shouldShowSetupWizard();
      
      if (mounted) {
        setState(() {
          _shouldShowSetup = shouldShow;
          _isLoading = false;
        });
      }
    } catch (e) {
      log.e('Error checking setup status: $e');
      
      if (mounted) {
        setState(() {
          _shouldShowSetup = true; // Default to showing setup on error
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Huoo Music',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      );
    }

    return _shouldShowSetup ? const WelcomeScreen() : const HomeScreen();
  }
}
