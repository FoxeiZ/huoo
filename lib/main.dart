import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:logger/logger.dart';

import 'package:huoo/screens/main_player.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/helpers/database_helper.dart';

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: BlocProvider(
        create: (context) => AudioPlayerBloc(),
        child: MainPlayer(),
      ),
    );
  }
}
