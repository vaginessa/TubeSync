import 'package:flutter/foundation.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class PlaylistProvider extends ChangeNotifier {
  final _ytClient = yt.YoutubeExplode().playlists;
  final Playlist playlist;
  final List<Media> medias = List.empty(growable: true);

  PlaylistProvider(this.playlist);

  Future<void> refresh() async {
    final vids = await _ytClient.getVideos(playlist.id).toList();
    medias.clear();
    medias.addAll(vids.map(Media.fromYTVideo));
    notifyListeners();
  }
}
