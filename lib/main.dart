import 'package:background_downloader/background_downloader.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/app_theme.dart';
import 'package:tube_sync/app/home_screen.dart';
import 'package:tube_sync/app/more/downloads/active_downloads_screen.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/model/preferences.dart';
import 'package:tube_sync/provider/media_provider.dart';

final rootNavigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DB Initialization
  final isarDB = Isar.open(
    schemas: [PreferencesSchema, PlaylistSchema, MediaSchema],
    directory: (await getApplicationSupportDirectory()).path,
  );

  AppTheme.dynamicColors.value = isarDB.preferences.getValue<bool>(
    Preference.materialYou,
  );

  // Limit concurrent downloads
  await FileDownloader().configure(
    globalConfig: (Config.holdingQueue, (3, 3, 3)),
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

  await MediaProvider().init();
  JustAudioMediaKit.ensureInitialized();

  runApp(
    ValueListenableBuilder(
      valueListenable: AppTheme.dynamicColors,
      builder: (_, dynamicColor, home) {
        if (dynamicColor == true) {
          return DynamicColorBuilder(
            builder: (light, dark) => MaterialApp(
              navigatorKey: rootNavigator,
              debugShowCheckedModeBanner: false,
              theme: AppTheme(colorScheme: light).light,
              darkTheme: AppTheme(colorScheme: dark).dark,
              scrollBehavior: AppTheme.scrollBehavior,
              home: home!,
            ),
          );
        }

        return MaterialApp(
          navigatorKey: rootNavigator,
          debugShowCheckedModeBanner: false,
          theme: AppTheme().light,
          darkTheme: AppTheme().dark,
          scrollBehavior: AppTheme.scrollBehavior,
          home: home!,
        );
      },
      child: Provider<Isar>(
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
