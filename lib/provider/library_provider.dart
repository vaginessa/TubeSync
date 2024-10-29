import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LibraryProvider extends ChangeNotifier {
  final Isar isar;
  final _ytClient = yt.YoutubeExplode().playlists;
  final List<Playlist> entries = List.empty(growable: true);

  LibraryProvider(this.isar) {
    entries.addAll(isar.playlists.where().findAll());
    notifyListeners();
    refresh();
  }

  Future<void> importPlaylist(String url) async {
    var playlist = await _ytClient.get(url);
    if (playlist.videoCount == 0) throw "Playlist is empty!";

    if (entries.contains(Playlist.fromYTPlaylist(playlist))) {
      throw "Playlist already exists!";
    }

    playlist = await _playlistWithThumbnail(playlist);

    entries.add(Playlist.fromYTPlaylist(playlist));
    isar.writeAsyncWith(entries.last, (db, data) => db.playlists.put(data));
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!await MediaProvider.hasInternet) return;
    for (final (index, playlist) in entries.indexed) {
      try {
        var update = await _ytClient.get(playlist.id);
        update = await _playlistWithThumbnail(update);
        entries[index] = Playlist.fromYTPlaylist(
          update,
          videoIds: entries[index].videoIds, // Pass previously cached videoIds
        );
      } catch (_) {
        // TODO Error
      }
    }

    isar.writeAsyncWith(entries, (db, data) => db.playlists.putAll(data));
    notifyListeners();
  }

  void delete(Playlist playlist) {
    entries.removeWhere((element) => element.id == playlist.id);
    isar.writeAsync(
      (isar) => isar.playlists.where().idEqualTo(playlist.id).deleteFirst(),
    );
    notifyListeners();
  }

  // Workaround for playlist thumbnail (thumb of first vid)
  // still no custom thumbnails tho
  Future<yt.Playlist> _playlistWithThumbnail(yt.Playlist playlist) async {
    return playlist.copyWith(
      thumbnails: yt.ThumbnailSet(
        (await _ytClient.getVideos(playlist.id).first).id.value,
      ),
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
