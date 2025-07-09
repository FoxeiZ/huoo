import 'package:equatable/equatable.dart';

class SongReference extends Equatable {
  final int id;
  final String title;
  final String path;

  const SongReference({
    required this.id,
    required this.title,
    required this.path,
  });

  factory SongReference.fromSong(dynamic song) {
    return SongReference(
      id: song.id ?? -1,
      title: song.title ?? 'Unknown',
      path: song.path ?? '',
    );
  }

  factory SongReference.fromMediaItem(dynamic mediaItem) {
    return SongReference(
      id: int.tryParse(mediaItem?.id?.toString() ?? '-1') ?? -1,
      title: mediaItem?.title ?? 'Unknown',
      path: mediaItem?.extras?['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'path': path};
  }

  factory SongReference.fromMap(Map<String, dynamic> map) {
    return SongReference(
      id: map['id'] ?? -1,
      title: map['title'] ?? 'Unknown',
      path: map['path'] ?? '',
    );
  }

  @override
  List<Object> get props => [id, title, path];

  @override
  String toString() => 'SongReference(id: $id, title: $title)';
}
