import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart';
import 'package:logger/logger.dart';

import 'package:huoo/models/song.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/helpers/database/types.dart';

final log = Logger(
  filter: DevelopmentFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

enum MediaScanProgressType {
  started,
  scanningFolders,
  filesFound,
  processingFile,
  processedFile,
  importingToDatabase,
  completed,
  error,
}

class MediaScanProgress {
  final MediaScanProgressType type;
  final String message;
  final int? processed;
  final int? total;
  final double? progress;
  final BulkImportResult? result;
  final String? error;
  final String? currentFile;

  MediaScanProgress({
    required this.type,
    required this.message,
    this.processed,
    this.total,
    this.progress,
    this.result,
    this.error,
    this.currentFile,
  });

  double get progressPercentage =>
      progress ??
      (processed != null && total != null ? processed! / total! : 0.0);

  bool get isCompleted => type == MediaScanProgressType.completed;
  bool get isError => type == MediaScanProgressType.error;

  @override
  String toString() =>
      'MediaScanProgress(type: $type, message: $message, progress: ${(progressPercentage * 100).toStringAsFixed(1)}%)';
}

class MediaScannerService {
  final List<String> _supportedExtensions = [
    'mp3',
    'wav',
    'flac',
    'aac',
    'ogg',
    'm4a',
    'opus',
  ];

  Isolate? _imageProcessingIsolate;
  StreamController<MediaScanProgress>? _progressController;

  /// Scan folders for music files and import them
  Stream<MediaScanProgress> scanFoldersStream(List<String> folderPaths) {
    _progressController = StreamController<MediaScanProgress>.broadcast();

    // Start the scanning process
    _performFolderScan(folderPaths);

    return _progressController!.stream;
  }

  Future<void> _performFolderScan(List<String> folderPaths) async {
    try {
      _emitProgress(MediaScanProgressType.started, 'Starting folder scan...');

      if (folderPaths.isEmpty) {
        _emitProgress(
          MediaScanProgressType.completed,
          'No folders specified for scanning',
          result: BulkImportResult(),
        );
        return;
      }

      // Scan folders for audio files
      _emitProgress(
        MediaScanProgressType.scanningFolders,
        'Scanning ${folderPaths.length} folders for audio files...',
      );

      final audioFiles = <File>[];
      for (final folderPath in folderPaths) {
        log.d('🔍 Processing folder path: "$folderPath"');

        // Check if the path is actually a file, not a folder
        final entity = await FileSystemEntity.type(folderPath);
        String actualFolderPath = folderPath;

        if (entity == FileSystemEntityType.file) {
          log.w('⚠️  Path is a file, not a folder: $folderPath');
          actualFolderPath = p.dirname(folderPath);
          log.d('📁 Using parent directory instead: $actualFolderPath');
        } else if (entity == FileSystemEntityType.notFound) {
          log.e('❌ Path does not exist: $folderPath');
          continue;
        }

        final folder = Directory(actualFolderPath);
        log.d('📁 Created Directory object for: ${folder.path}');

        if (await folder.exists()) {
          log.d('✅ Folder exists, starting scan...');
          final files = await _scanFolderRecursively(folder);
          log.d('📊 Scan returned ${files.length} audio files');
          audioFiles.addAll(files);
        } else {
          log.w('❌ Folder does not exist: $actualFolderPath');
          log.w('   Absolute path would be: ${folder.absolute.path}');
        }
      }

      if (audioFiles.isEmpty) {
        _emitProgress(
          MediaScanProgressType.completed,
          'No audio files found in specified folders',
          result: BulkImportResult(),
        );
        return;
      }

      _emitProgress(
        MediaScanProgressType.filesFound,
        'Found ${audioFiles.length} audio files',
        total: audioFiles.length,
      );

      // Initialize image processing isolate
      await _initializeImageProcessingIsolate();

      // First pass: Collect and prepare all song data for bulk import
      _emitProgress(
        MediaScanProgressType.processingFile,
        'Preparing songs for bulk import...',
      );

      final songDataList = <Map<String, dynamic>>[];
      int processed = 0;
      int skipped = 0;

      for (final audioFile in audioFiles) {
        try {
          _emitProgress(
            MediaScanProgressType.processingFile,
            'Preparing: ${p.basename(audioFile.path)}',
            processed: processed,
            total: audioFiles.length,
            currentFile: p.basename(audioFile.path),
          );

          // Check if song already exists in database
          final existingSong = await DatabaseHelper().songProvider.getByPath(
            audioFile.path,
          );
          if (existingSong != null) {
            skipped++;
            processed++;
            continue;
          }

          // Convert audio file to song data for bulk import
          final songData = await _convertAudioFileToSongData(audioFile);
          if (songData != null) {
            songDataList.add(songData);
          } else {
            skipped++;
          }

          processed++;
        } catch (e) {
          log.e('Error preparing song ${audioFile.path}: $e');
          skipped++;
          processed++;
        }
      }

      if (songDataList.isEmpty) {
        await _disposeImageProcessingIsolate();
        _emitProgress(
          MediaScanProgressType.completed,
          'No new songs to import ($skipped already exist or unsupported)',
          result: BulkImportResult(),
        );
        return;
      }

      // Second pass: Use optimized bulk import for maximum performance
      _emitProgress(
        MediaScanProgressType.importingToDatabase,
        'Importing ${songDataList.length} songs using optimized bulk import...',
      );

      final result = await DatabaseHelper().optimizedBulkImportSongs(
        songDataList: songDataList,
        chunkSize: 25, // Smaller chunks for better progress tracking
        onProgress: (importProcessed, importTotal) {
          _emitProgress(
            MediaScanProgressType.importingToDatabase,
            'Optimized bulk importing: $importProcessed/$importTotal songs',
            processed: importProcessed,
            total: importTotal,
          );
        },
      );

      // Clean up isolate
      await _disposeImageProcessingIsolate();

      _emitProgress(
        MediaScanProgressType.completed,
        'Import completed: ${result.successCount} successful, ${result.failureCount} failed, $skipped skipped',
        result: result,
      );
    } catch (e) {
      log.e('Error during folder scan: $e');
      await _disposeImageProcessingIsolate();
      _emitProgress(
        MediaScanProgressType.error,
        'Scan failed: $e',
        error: e.toString(),
      );
    } finally {
      await _progressController?.close();
      _progressController = null;
    }
  }

  void _emitProgress(
    MediaScanProgressType type,
    String message, {
    int? processed,
    int? total,
    double? progress,
    BulkImportResult? result,
    String? error,
    String? currentFile,
  }) {
    final progressUpdate = MediaScanProgress(
      type: type,
      message: message,
      processed: processed,
      total: total,
      progress: progress,
      result: result,
      error: error,
      currentFile: currentFile,
    );

    log.d(progressUpdate.toString());
    _progressController?.add(progressUpdate);
  }

  /// Recursively scan a folder for audio files
  Future<List<File>> _scanFolderRecursively(Directory folder) async {
    final audioFiles = <File>[];
    int totalFiles = 0;
    int audioFilesFound = 0;
    int totalDirectories = 0;
    final extensionCounts = <String, int>{};

    log.d('📁 Starting recursive scan of folder: ${folder.path}');
    log.d('🎵 Supported extensions: $_supportedExtensions');

    // First, check if the folder exists and is readable
    try {
      final exists = await folder.exists();
      log.d('📋 Folder exists: $exists');

      if (!exists) {
        log.e('❌ Folder does not exist: ${folder.path}');
        return audioFiles;
      }

      // Try to list just the immediate contents first
      log.d('🔍 Testing folder access by listing immediate contents...');

      try {
        final immediateContents = await folder.list().toList();
        log.d('📂 Immediate contents count: ${immediateContents.length}');

        for (final item in immediateContents) {
          final itemPath = item.path;
          final itemName = p.basename(itemPath);
          final itemExt = p.extension(itemPath);

          if (item is Directory) {
            log.d('   📁 Directory: "$itemName" (full path: "$itemPath")');
          } else if (item is File) {
            log.d(
              '   📄 File: "$itemName" (ext: "$itemExt", full path: "$itemPath")',
            );
          } else {
            log.d(
              '   🔗 Other: "$itemName" (${item.runtimeType}, full path: "$itemPath")',
            );
          }
        }
      } catch (e) {
        log.e('❌ PERMISSION ERROR - Cannot list folder contents: $e');
        log.e('❌ Error type: ${e.runtimeType}');

        if (e is FileSystemException) {
          log.e('❌ FileSystemException details:');
          log.e('   - Path: ${e.path}');
          log.e('   - Message: ${e.message}');
          log.e('   - OS Error: ${e.osError}');

          // Check if this is a permission error
          final messageContainsPermission = e.message.toLowerCase().contains(
            'permission',
          );
          final osErrorMessage = e.osError?.message;
          final osErrorContainsPermission =
              osErrorMessage != null &&
              osErrorMessage.toLowerCase().contains('permission');

          if (messageContainsPermission || osErrorContainsPermission) {
            log.e('🚫 THIS IS A PERMISSION ISSUE!');
            log.e(
              '   The app needs storage permissions to access this folder.',
            );
            log.e('   Please grant storage permissions in the app settings.');
          }
        }

        // Return empty list if we can't access the folder
        return audioFiles;
      }
    } catch (e) {
      log.e('❌ Error checking folder access: $e');
      return audioFiles;
    }

    // Now try the recursive scan
    log.d('🔄 Starting recursive scan...');

    try {
      await for (final entity in folder.list(recursive: true)) {
        log.d('🔍 Entity found: ${entity.path} (${entity.runtimeType})');

        if (entity is File) {
          totalFiles++;
          final rawPath = entity.path;
          final fullExtension = p.extension(rawPath).toLowerCase();
          final extension =
              fullExtension.isNotEmpty ? fullExtension.substring(1) : '';
          final fileName = p.basename(rawPath);

          // Count all extensions we encounter
          extensionCounts[extension] = (extensionCounts[extension] ?? 0) + 1;

          log.d('📄 File details:');
          log.d('   🗂️  Raw path: "$rawPath"');
          log.d('   📂 Directory: "${p.dirname(rawPath)}"');
          log.d('   📄 Filename: "$fileName"');
          log.d('   📝 Full extension: "$fullExtension"');
          log.d('   🔤 Extension only: "$extension"');
          log.d(
            '   ✨ Is supported: ${_supportedExtensions.contains(extension)}',
          );

          if (_supportedExtensions.contains(extension)) {
            log.d('✅ Audio file detected: $fileName (.$extension)');
            audioFiles.add(entity);
            audioFilesFound++;
          } else {
            log.d('❌ Skipping unsupported file: $fileName (.$extension)');
          }
        } else if (entity is Directory) {
          totalDirectories++;
          log.d('📂 Directory found: ${entity.path}');
        } else {
          log.d('🔗 Other entity type: ${entity.path} (${entity.runtimeType})');
        }
      }

      log.d('📊 Scan completed for ${folder.path}:');
      log.d('   📁 Total files scanned: $totalFiles');
      log.d('   📂 Total directories found: $totalDirectories');
      log.d('   🎵 Audio files found: $audioFilesFound');
      log.d('   📈 Extension breakdown: $extensionCounts');

      if (totalFiles == 0) {
        log.w('⚠️  NO FILES FOUND AT ALL in ${folder.path}');
        log.w(
          '   This might be a permissions issue or the folder might be empty',
        );
      } else if (audioFilesFound == 0 && totalFiles > 0) {
        log.w(
          '⚠️  No audio files found despite $totalFiles files being present!',
        );
        log.w(
          '   🔍 Check if your files have these extensions: $_supportedExtensions',
        );
        log.w(
          '   📋 Files found with extensions: ${extensionCounts.keys.toList()}',
        );
      }
    } catch (e) {
      log.e('💥 Error during recursive scan of ${folder.path}: $e');
      log.e('💥 Error details: ${e.runtimeType}');
      if (e is FileSystemException) {
        log.e('💥 FileSystemException details:');
        log.e('   - Path: ${e.path}');
        log.e('   - Message: ${e.message}');
        log.e('   - OS Error: ${e.osError}');
      }
    }

    return audioFiles;
  }

  Future<Map<String, dynamic>?> _convertAudioFileToSongData(
    File audioFile,
  ) async {
    try {
      final song = await Song.fromLocalFile(audioFile.path);
      final album = await song.getAlbum();

      final artists = <Artist>[];
      if (song.artists.isNotEmpty) {
        for (final artist in song.artists) {
          if (artist != null && artist.name.isNotEmpty) {
            artists.add(artist);
          }
        }
      }

      // If no artists found, create a default one from the directory or filename
      if (artists.isEmpty) {
        artists.add(Artist(name: "Unknown Artist"));
      }

      String? coverPath = song.cover;
      if (coverPath == null) {
        try {
          final directoryPath = p.dirname(audioFile.path);
          final coverFiles = [
            'cover.jpg',
            'cover.png',
            'folder.jpg',
            'folder.png',
            'album.jpg',
            'album.png',
          ];

          for (final coverFileName in coverFiles) {
            final coverFile = File(p.join(directoryPath, coverFileName));
            if (await coverFile.exists()) {
              final coverData = await coverFile.readAsBytes();
              coverPath = await _processImageInIsolate(coverData);
              break;
            }
          }
        } catch (e) {
          log.w('Failed to process cover art for ${audioFile.path}: $e');
        }
      }

      final finalSong =
          coverPath != null && coverPath != song.cover
              ? song.copyWith(cover: coverPath)
              : song;

      return {'song': finalSong, 'album': album, 'artists': artists};
    } catch (e) {
      log.e('Error converting audio file ${audioFile.path}: $e');
      return null;
    }
  }

  Future<BulkImportResult> scanFolders({
    required List<String> folderPaths,
    Function(int processed, int total)? onProgress,
    Function(String message)? onStatusUpdate,
  }) async {
    final completer = Completer<BulkImportResult>();

    scanFoldersStream(folderPaths).listen(
      (progress) {
        onStatusUpdate?.call(progress.message);
        if (progress.processed != null && progress.total != null) {
          onProgress?.call(progress.processed!, progress.total!);
        }

        if (progress.isCompleted) {
          completer.complete(progress.result ?? BulkImportResult());
        } else if (progress.isError) {
          completer.completeError(progress.error ?? 'Unknown error');
        }
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    return completer.future;
  }

  Future<void> _initializeImageProcessingIsolate() async {
    if (_imageProcessingIsolate != null) return;

    final receivePort = ReceivePort();
    _imageProcessingIsolate = await Isolate.spawn(
      _imageProcessingIsolateEntry,
      receivePort.sendPort,
    );
  }

  Future<String?> _processImageInIsolate(Uint8List imageData) async {
    if (_imageProcessingIsolate == null) {
      await _initializeImageProcessingIsolate();
    }

    final receivePort = ReceivePort();
    final appDir = await getApplicationDocumentsDirectory();
    final coverDir = Directory('${appDir.path}/covers');

    final request = ImageProcessingRequest(
      imageData: imageData,
      coverDirPath: coverDir.path,
      responsePort: receivePort.sendPort,
      resizeWidth: 500,
      resizeHeight: 500,
    );

    // Send request to isolate
    final sendPort = await receivePort.first as SendPort;
    sendPort.send(request);

    // Wait for response
    final response = await receivePort.skip(1).first as ImageProcessingResponse;

    if (response.success) {
      return response.coverPath;
    } else {
      log.e('Image processing failed: ${response.error}');
      return null;
    }
  }

  Future<void> _disposeImageProcessingIsolate() async {
    _imageProcessingIsolate?.kill(priority: Isolate.immediate);
    _imageProcessingIsolate = null;
  }

  static void _imageProcessingIsolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) async {
      if (message is ImageProcessingRequest) {
        try {
          final coverPath = await _processImageData(
            message.imageData,
            message.coverDirPath,
            resizeWidth: message.resizeWidth,
            resizeHeight: message.resizeHeight,
          );

          message.responsePort.send(
            ImageProcessingResponse(success: true, coverPath: coverPath),
          );
        } catch (e) {
          message.responsePort.send(
            ImageProcessingResponse(success: false, error: e.toString()),
          );
        }
      }
    });
  }

  static Future<String?> _processImageData(
    Uint8List imageData,
    String coverDirPath, {
    int resizeWidth = 500,
    int resizeHeight = 500,
  }) async {
    try {
      // Ensure cover directory exists
      final coverDir = Directory(coverDirPath);
      if (!await coverDir.exists()) {
        await coverDir.create(recursive: true);
      }

      // Decode image
      Image? image = decodeImage(imageData);
      if (image == null) return null;

      // Resize image
      image = copyResize(image, width: resizeWidth, height: resizeHeight);

      // Generate filename based on content hash
      final imageBytes = encodeJpg(image, quality: 85);
      final checksum = md5.convert(imageBytes);
      final fileName = '${checksum.toString()}.jpg';
      final coverFile = File(p.join(coverDirPath, fileName));

      // Save if doesn't exist
      if (!await coverFile.exists()) {
        await coverFile.writeAsBytes(imageBytes);
      }

      return coverFile.path;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  void cancelScan() {
    _progressController?.close();
    _progressController = null;
    _disposeImageProcessingIsolate();
  }

  bool get isScanning =>
      _progressController != null && !_progressController!.isClosed;
}

class ImageProcessingRequest {
  final Uint8List imageData;
  final String coverDirPath;
  final SendPort responsePort;
  final int resizeWidth;
  final int resizeHeight;

  ImageProcessingRequest({
    required this.imageData,
    required this.coverDirPath,
    required this.responsePort,
    this.resizeWidth = 500,
    this.resizeHeight = 500,
  });
}

class ImageProcessingResponse {
  final bool success;
  final String? coverPath;
  final String? error;

  ImageProcessingResponse({required this.success, this.coverPath, this.error});
}
