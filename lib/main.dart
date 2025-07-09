import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:logger/logger.dart';

import 'package:huoo/screens/welcome_screen.dart';
import 'package:huoo/screens/home_screen.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/helpers/database/helper.dart';

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
  runApp(const MyApp(isTest: true));
}

class MyApp extends StatelessWidget {
  final bool isTest;
  static final AudioPlayerBloc _audioPlayerBloc = AudioPlayerBloc();

  const MyApp({super.key, this.isTest = false});

  Widget _buildTest(BuildContext context) {
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
        home: const WelcomeScreen(),
      ),
    );
  }

  Widget _build(BuildContext context) {
    return BlocProvider.value(
      value: _audioPlayerBloc,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isTest) {
      return _buildTest(context);
    }
    return _build(context);
  }
}
