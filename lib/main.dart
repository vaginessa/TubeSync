import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/app_theme.dart';
import 'package:tube_sync/app/home_screen.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/model/preferences.dart';
import 'package:tube_sync/services/downloader_service.dart';
import 'package:tube_sync/services/media_service.dart';

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

  await DownloaderService.init();
  await MediaService.init();

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
  Permission.notification.isDenied.then((denied) {
    if (denied) Permission.notification.request();
  });

  // Ensure battery optimization disabled
  Permission.ignoreBatteryOptimizations.isDenied.then((denied) {
    if (denied) Permission.ignoreBatteryOptimizations.request();
  });
}
