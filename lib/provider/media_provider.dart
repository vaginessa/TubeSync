import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tube_sync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaProvider {
  MediaProvider._();

  static final MediaProvider _instance = MediaProvider._();

  factory MediaProvider() => _instance;

  Future<void> init() async {
    final dir = await getApplicationCacheDirectory();
    mediaFileDir = dir.path + Platform.pathSeparator;
  }

  late final String mediaFileDir;
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;

  bool _abortQueueing = false;

  File mediaFile(Media media) => File(mediaFileDir + media.id);

  Future<Source?> getMedia(Media media) async {
    // Try from offline
    final downloaded = mediaFile(media);
    if (downloaded.existsSync()) return DeviceFileSource(downloaded.path);

    if (!await hasInternet) return null;

    final videoManifest = await _ytClient.getManifest(media.id);
    final streamUri = videoManifest.audioOnly.withHighestBitrate().url;
    return UrlSource(streamUri.toString());
  }

  Future<void> download(Media media) async {
    try {
      if (isDownloaded(media)) return;
      final manifest = await _ytClient.getManifest(media.id);
      final url = manifest.audioOnly.withHighestBitrate().url.toString();

      final task = DownloadTask(
        url: url,
        displayName: media.title,
        directory: mediaFileDir,
        filename: media.id,
        baseDirectory: BaseDirectory.root,
        updates: Updates.statusAndProgress,
      );

      await FileDownloader().enqueue(task);
    } catch (_) {
      //TODO Error
    }
  }

  Future<void> downloadAll(List<Media> medias) async {
    _abortQueueing = false;
    for (final media in medias) {
      try {
        if (isDownloaded(media)) continue;

        final manifest = await _ytClient.getManifest(media.id);
        final url = manifest.audioOnly.withHighestBitrate().url.toString();

        if (_abortQueueing) break;

        FileDownloader().enqueue(DownloadTask(
          url: url,
          displayName: media.title,
          directory: mediaFileDir,
          filename: media.id,
          baseDirectory: BaseDirectory.root,
          updates: Updates.statusAndProgress,
        ));
      } catch (_) {
        // TODO Error
      }
    }
  }

  void abortQueueing() => _abortQueueing = true;

  bool isDownloaded(Media media) => mediaFile(media).existsSync();

  void delete(Media media) {
    final file = mediaFile(media);
    if (file.existsSync()) file.deleteSync();
  }

  static Future<bool> get hasInternet => InternetConnection().hasInternetAccess;
}
