import 'package:isar/isar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'common.g.dart';

@embedded
class Thumbnails {
 final String low, medium, high;

  Thumbnails(this.low, this.medium, this.high);

  factory Thumbnails.fromYTThumbnails(ThumbnailSet thumbs) =>
      Thumbnails(thumbs.lowResUrl, thumbs.mediumResUrl, thumbs.highResUrl);
}
