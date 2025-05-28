# Huoo
> Why Huoo?

Name based on my favourite character in HSR - [HuoHuo](https://starrailstation.com/en/character/huohuo). (please don't sue me, HoYoverse)

### Disclaimer 
This project is not affiliated with or endorsed by HoYoverse. The name "Huoo" is used for 
educational purposes only and does not imply any association with the company or its products.

### ⚠️ Warning
It is still in early development, so expect bugs and missing features.


## Running
Just get the dependencies, build, and install like any other Flutter project.
Or you are too lazy to google it yourself; here is a TL;DR.
```
> flutter pub get

# If you are on Windows, you don't need to run this command
> flutter pub run flutter_native_splash:create

# Android flavor
> flutter build apk --release
> flutter install

# Windows/Linux/MacOS flavor
> flutter build <platform> --release

# Or simply just run
> flutter run --release
```

## Acknowledgements

This project would not be possible without the following open-source packages:

- [flutter](https://flutter.dev) - Google's UI toolkit for building natively compiled applications
- [flutter_native_splash](https://github.com/jonbhanson/flutter_native_splash) - Automatically generates native code for adding splash screens in Android and iOS. Customize with specific platform, background color and splash image.
- [shared_preferences](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) - A Flutter plugin for reading and writing simple key-value pairs.
- [audio_metadata_reader](https://github.com/ClementBeal/audio_metadata_reader) - A pure-dart audio metadata reader
- [just_waveform](https://github.com/ryanheise/just_waveform) - A Flutter plugin to extract waveform data from an audio file suitable for visual rendering.
- [media_kit](https://github.com/media-kit/media-kit) - A cross-platform video player & audio player for Flutter & Dart.
- [just_audio](https://github.com/ryanheise/just_audio) - A feature-rich audio player for Android, iOS, macOS, web, Linux and Windows.
- [flutter_bloc](https://github.com/felangel/bloc) - A predictable state management library that helps implement the BLoC design pattern
- [equatable](https://github.com/felangel/equatable) - A Dart package that helps to implement value equality without needing to explicitly override == and hashCode.

Thanks to all the developers who maintain these packages.