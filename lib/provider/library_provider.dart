import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LibraryProvider extends ChangeNotifier {
  final Isar isar;
  final _ytClient = yt.YoutubeExplode().playlists;
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider(this.isar) {
    entries.addAll(isar.playlists.where().findAll());
  }

  Future<void> importPlaylist(String url) async {
    var playlist = await _ytClient.get(url);
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    if (entries.contains(Playlist.fromYTPlaylist(playlist))) {
      throw "Playlist already exists!";
    }

    // Workaround for playlist thumbnail (thumb of first vid)
    // still no custom thumbnails tho
    playlist = playlist.copyWith(
      thumbnails: yt.ThumbnailSet(
        (await _ytClient.getVideos(playlist.id).first).id.value,
      ),
    );

    entries.add(Playlist.fromYTPlaylist(playlist));
    isar.writeAsyncWith(entries.last, (db, data) => db.playlists.put(data));
    notifyListeners();
  }

  Future<void> refresh() async {
    //
  }
}
