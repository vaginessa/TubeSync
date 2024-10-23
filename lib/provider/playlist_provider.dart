import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class PlaylistProvider extends ChangeNotifier {
  final Isar isar;
  final _ytClient = yt.YoutubeExplode().playlists;
  final Playlist playlist;
  final List<Media> medias = List.empty(growable: true);

  PlaylistProvider(this.isar, this.playlist) {
    for (final id in playlist.videoIds) {
      final media = isar.medias.where().idEqualTo(id).findFirst();
      if (media != null) medias.add(media);
    }
    updateDownloadedStatus();
  }

  Future<void> refresh() async {
    final vids = await _ytClient.getVideos(playlist.id).toList();
    medias.clear();
    medias.addAll(vids.map(Media.fromYTVideo));
    // Update playlist
    playlist.videoIds.clear();
    playlist.videoIds.addAll(medias.map((m) => m.id));
    // Save to DB
    isar.writeAsyncWith(playlist, (db, data) => db.playlists.put(data));
    isar.writeAsyncWith(medias, (db, data) => db.medias.putAll(data));

    await updateDownloadedStatus();
    notifyListeners();
  }

  Future<void> updateDownloadedStatus() async {
    for (final media in medias) {
      media.downloaded = await MediaProvider.isDownloaded(media);
    }

    notifyListeners();
  }

  void notify() => super.notifyListeners();

  Future<void> downloadMedia(Media media) async {
    await MediaProvider.download(media);
    medias.firstWhere((e) => e.id == media.id).downloaded =
        await MediaProvider.isDownloaded(media);
    notifyListeners();
  }
}
