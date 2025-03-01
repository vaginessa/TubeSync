import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tubesync/app/more/downloads/active_downloads_screen.dart';
import 'package:tubesync/main.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/services/media_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class DownloaderService {
  /// <-- Singleton
  DownloaderService._();

  static final DownloaderService _instance = DownloaderService._();

  factory DownloaderService() => _instance;

  /// Singleton -->
  /// Must call before runApp
  static Future<void> init() async {
    await FileDownloader().configure(
      globalConfig: [
        // Limit concurrent downloads
        (Config.holdingQueue, (3, 3, 3)),
        // >100mb space available
        (Config.checkAvailableSpace, 100),
        // Use background service when possible
        (Config.runInForeground, Config.always),
      ],
    );

    // Background downloader notifications
    FileDownloader().configureNotification(
      running: TaskNotification('Downloading', '{displayName}'),
      complete: TaskNotification('Download finished', '{displayName}'),
      progressBar: true,
    );

    // Register notification tap handler / download listener
    FileDownloader().registerCallbacks(
      taskNotificationTapCallback: DownloaderService.notificationTapHandler,
      taskStatusCallback: DownloaderService.downloadStatusListener,
    );

    // Using the database to track Tasks
    FileDownloader().trackTasks();
  }

  final _ytClient = yt.YoutubeExplode().videos.streamsClient;
  bool _abortQueueing = false;

  void abortQueueing() => _abortQueueing = true;

  Future<void> download(Media media) async {
    try {
      if (MediaService().isDownloaded(media)) return;
      final manifest = await compute(
        (data) => (data[0] as yt.StreamClient).getManifest(data[1]),
        [_ytClient, media.id],
      );
      final url = manifest.audioOnly.withHighestBitrate().url.toString();

      final task = DownloadTask(
        url: url,
        displayName: media.title,
        directory: MediaService().downloadsDir,
        filename: media.id,
        baseDirectory: BaseDirectory.root,
        updates: Updates.statusAndProgress,
      );

      await FileDownloader().enqueue(task);
    } catch (_) {
      //TODO Error
    }
  }

  // TODO Move this process to background or notify user to not close until this finishes
  // https://pub.dev/packages/workmanager or https://pub.dev/packages/flutter_background_service
  Future<void> downloadAll(List<Media> medias) async {
    _abortQueueing = false;
    for (final media in medias) {
      try {
        if (MediaService().isDownloaded(media)) continue;

        final manifest = await compute(
          (data) => (data[0] as yt.StreamClient).getManifest(data[1]),
          [_ytClient, media.id],
        );
        final url = manifest.audioOnly.withHighestBitrate().url.toString();

        if (_abortQueueing) break;

        FileDownloader().enqueue(DownloadTask(
          url: url,
          displayName: media.title,
          directory: MediaService().downloadsDir,
          filename: media.id,
          baseDirectory: BaseDirectory.root,
          updates: Updates.statusAndProgress,
        ));
      } catch (_) {
        // TODO Error
      }
    }
  }

  Future<void> cancelAll() async {
    FileDownloader().taskQueues.forEach(FileDownloader().removeTaskQueue);
    DownloaderService().abortQueueing();
    Iterable<TaskRecord> records = await FileDownloader().database.allRecords();

    await FileDownloader().cancelTasksWithIds(
      records.map((e) => e.taskId).toList(),
    );
    await FileDownloader().database.deleteAllRecords();
  }

  // ------ Proxy Methods -------- //

  Database get db => FileDownloader().database;

  void registerCallbacks({
    TaskStatusCallback? taskStatusCallback,
    TaskProgressCallback? taskProgressCallback,
    TaskNotificationTapCallback? taskNotificationTapCallback,
  }) {
    FileDownloader().registerCallbacks(
      taskStatusCallback: taskStatusCallback,
      taskProgressCallback: taskProgressCallback,
      taskNotificationTapCallback: taskNotificationTapCallback,
    );
  }

  void unregisterCallbacks({Function? callback}) =>
      FileDownloader().unregisterCallbacks(callback: callback);

  static Future<bool> get hasInternet => InternetConnection().hasInternetAccess;

  // ------ Static Listeners -------- //

  static void notificationTapHandler(
    Task task,
    NotificationType notificationType,
  ) {
    rootNavigator.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ActiveDownloadsScreen()),
      (route) => route.isFirst,
    );
  }

  static void downloadStatusListener(TaskStatusUpdate update) {
    switch (update.status) {
      case TaskStatus.complete:
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        FileDownloader().database.deleteRecordWithId(update.task.taskId);
        break;

      default:
        break;
    }
  }
}

typedef DownloadRecord = TaskRecord;
typedef DownloadProgressUpdate = TaskProgressUpdate;
typedef DownloadStatusUpdate = TaskStatusUpdate;
typedef DownloadStatus = TaskStatus;
