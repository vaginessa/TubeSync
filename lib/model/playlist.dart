import 'package:isar/isar.dart';
import 'package:tube_sync/model/common.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'playlist.g.dart';

@collection
class Playlist {
  @Id()
  final String id;
  final String title, author;

  final String? description;

  final Thumbnails thumbnail;
  final int videoCount;

  final List<String> videoIds;

  Playlist(
    this.id,
    this.title,
    this.author,
    this.thumbnail,
    this.videoCount,
    this.description,
    this.videoIds,
  );

  factory Playlist.fromYTPlaylist(yt.Playlist playlist) => Playlist(
        playlist.id.value,
        playlist.title,
        playlist.author,
        Thumbnails.fromYTThumbnails(playlist.thumbnails),
        playlist.videoCount ?? -1,
        playlist.description.isNotEmpty ? playlist.description : null,
        List.empty(growable: true),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist{id: $id, title: $title, author: $author, description: $description, thumbnail: $thumbnail, videoCount: $videoCount, videoIds: $videoIds}';
  }
}
