import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tube_sync/model/media.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaProvider {
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;

  Future<Source?> getMedia(Media media) async {
    // Try from offline
    final downloaded = File(await mediaFilePath(media));
    if (downloaded.existsSync()) return DeviceFileSource(downloaded.path);

    if (!await hasInternet) return null;

    final videoManifest = await _ytClient.getManifest(media.id);
    final streamUri = videoManifest.audioOnly.withHighestBitrate().url;
    final source = UrlSource(streamUri.toString());

    return source;
  }

  static Future<String> mediaFilePath(Media media) async {
    // return "/home/khaled/.cache/tubesync.app/${media.id}";
    final dir = await getApplicationCacheDirectory();
    return dir.path + Platform.pathSeparator + media.id;
  }

  static Future<void> download(Media media) async {
    final ytClient = yt.YoutubeExplode().videos.streamsClient;
    final manifest = await ytClient.getManifest(media.id);
    final url = manifest.audioOnly.withHighestBitrate().url.toString();
    final directory = await mediaFilePath(media);

    final task = DownloadTask(
      url: url,
      displayName: media.title,
      directory: directory.replaceFirst(media.id, ''),
      filename: media.id,
      baseDirectory: BaseDirectory.root,
      updates: Updates.statusAndProgress,
    );
    await FileDownloader().enqueue(task);
    await FileDownloader().database.recordForId(task.taskId);
  }

  static Future<bool> isDownloaded(Media media) async {
    return File(await mediaFilePath(media)).exists();
  }

  static Future<void> delete(Media media) async {
    final file = File(await mediaFilePath(media));
    if (file.existsSync()) await file.delete();
  }

  Future<bool> get hasInternet => InternetConnection().hasInternetAccess;
}
