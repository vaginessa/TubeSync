import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LibraryProvider extends ChangeNotifier {
  final _ytClient = YoutubeExplode().playlists;
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider();

  Future<void> importPlaylist(String url) async {
    final playlist = await _ytClient.get(url);
    // https://github.com/Hexer10/youtube_explode_dart/issues/298
    if (entries.firstWhereOrNull((e) => e.id == playlist.id) != null) {
      throw "Playlist already exists!";
    }
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    // Workaround for playlist thumbnail (still no custom thumbnails)
    final video = await _ytClient.getVideos(playlist.id).first;
    entries.add(playlist.copyWith(thumbnails: ThumbnailSet(video.id.value)));
    notifyListeners();
  }
}
