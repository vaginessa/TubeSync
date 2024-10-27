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
    updateDownloadedStatus(notify: true);
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

  Future<void> updateDownloadedStatus({
    Media? onlyOf,
    bool notify = false,
  }) async {
    if (onlyOf != null) {
      final index = medias.indexWhere((e) => e.id == onlyOf.id);
      // notifying won't work for nested
      medias[index] = medias[index]
        ..downloaded = await MediaProvider.isDownloaded(medias[index]);
    } else {
      for (final media in medias) {
        media.downloaded = await MediaProvider.isDownloaded(media);
      }
    }
    if (notify && mounted) notifyListeners();
  }

  Future<void> downloadMedia(Media media) async {
    await MediaProvider.download(media);
    updateDownloadedStatus(onlyOf: media);
    notifyListeners();
  }

  Future<void> deleteMedia(Media media) async {
    await MediaProvider.delete(media);
    updateDownloadedStatus(onlyOf: media);
    notifyListeners();
  }

  Future<void> downloadAll() async {
    //
  }




  @override
  void dispose() {
    super.dispose();
    _mounted = false;
  }

  bool _mounted = false;

  bool get mounted => _mounted;

}
