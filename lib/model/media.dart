import 'package:isar/isar.dart';
import 'package:tube_sync/model/common.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

part 'media.g.dart';

@collection
class Media {
  // ignore: unused_field isar auto-generated id
  Id? _id;

  final String id, title, author;

  final String? description;

  int? durationMs;

  final Thumbnails thumbnail;

  @ignore
  bool? downloaded;

  @ignore
  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);

  Media(
    this.id,
    this.title,
    this.author,
    this.description,
    this.durationMs,
    this.thumbnail,
  );

  factory Media.fromYTVideo(yt.Video video) => Media(
        video.id.value,
        video.title,
        video.author,
        video.description,
        video.duration?.inMilliseconds,
        Thumbnails.fromYTThumbnails(video.thumbnails),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Media && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Media{_id: $_id, id: $id, title: $title, author: $author, description: $description, durationMs: $durationMs, thumbnail: $thumbnail}';
  }
}
