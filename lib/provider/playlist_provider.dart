import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistProvider extends ChangeNotifier {
  final _ytClient = YoutubeExplode().playlists;
  final Playlist playlist;
  final List<Video> videos = List.empty(growable: true);

  PlaylistProvider(this.playlist);

  Future<void> refresh() async {
    final vids = await _ytClient.getVideos(playlist.id.value).toList();
    videos.clear();
    videos.addAll(vids);
    notifyListeners();
  }
}
