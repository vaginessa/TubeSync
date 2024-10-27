import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/app_theme.dart';
import 'package:tube_sync/app/home_screen.dart';
import 'package:tube_sync/app/more/downloads/active_downloads_screen.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';

final rootNavigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DB Initialization
  final isarDB = Isar.open(
    schemas: [PlaylistSchema, MediaSchema],
    directory: (await getApplicationSupportDirectory()).path,
  );

  // Background downloader notifications
  FileDownloader().configureNotification(
    running: TaskNotification('Downloading', '{displayName}'),
    complete: TaskNotification('Download finished', '{displayName}'),
    progressBar: true,
  );

  // Register notification tap handler / download listener
  FileDownloader().registerCallbacks(
    taskNotificationTapCallback: ActiveDownloadsScreen.notificationTapHandler,
    taskStatusCallback: ActiveDownloadsScreen.downloadStatusListener,
  );

  // Using the database to track Tasks
  FileDownloader().trackTasks();

  runApp(
    MaterialApp(
      navigatorKey: rootNavigator,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      scrollBehavior: AppTheme.scrollBehavior,
      home: Provider<Isar>(
        create: (context) => isarDB,
        child: const HomeScreen(),
      ),
    ),
  );

  // Ensure notification permission
  Permission.notification.isDenied.then((value) {
    if (value) Permission.notification.request();
  });
}
