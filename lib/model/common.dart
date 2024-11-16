import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'common.g.dart';

@embedded
class Thumbnails {
  //low, high has vertical black borders
  final String low, medium, high;

  Thumbnails(this.low, this.medium, this.high);

  factory Thumbnails.fromYTThumbnails(ThumbnailSet thumbs) =>
      Thumbnails(thumbs.lowResUrl, thumbs.mediumResUrl, thumbs.highResUrl);

  @override
  String toString() {
    return 'Thumbnails{low: $low, medium: $medium, high: $high}';
  }
}

@JsonSerializable()
class LastPlayedMedia {
  String playlistId;
  String mediaId;

  LastPlayedMedia({
    required this.playlistId,
    required this.mediaId,
  });

  factory LastPlayedMedia.fromJson(Map<String, dynamic> json) =>
      _$LastPlayedMediaFromJson(json);

  Map<String, dynamic> toJson() => _$LastPlayedMediaToJson(this);
}
