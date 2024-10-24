import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/playlist_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaProvider {
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;

  final PlaylistProvider playlist;
  late ValueNotifier<Media> nowPlayingNotifier;

  Media get nowPlaying => nowPlayingNotifier.value;

  MediaProvider(this.playlist, Media? initialMedia) {
    nowPlayingNotifier = ValueNotifier(initialMedia ?? playlist.medias.first);
  }

  Future<Source> getMedia() async {
    // Try from offline
    final downloaded = File(await mediaFilePath(nowPlaying));
    if (downloaded.existsSync()) return DeviceFileSource(downloaded.path);

    // Fallback to online
    // TODO Skip on no internet
    final videoManifest = await _ytClient.getManifest(nowPlaying.id);
    final streamUri = videoManifest.audioOnly.withHighestBitrate().url;
    final source = UrlSource(streamUri.toString());

    return source;
  }

  void previousTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying);
    if (currentIndex == 0) return;
    nowPlayingNotifier.value = playlist.medias[currentIndex - 1];
  }

  void nextTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying);
    if (currentIndex + 1 == playlist.medias.length) return;
    nowPlayingNotifier.value = playlist.medias[currentIndex + 1];
  }

  void dispose() {
    nowPlayingNotifier.dispose();
  }

  static Future<String> mediaFilePath(Media media) async {
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
}
