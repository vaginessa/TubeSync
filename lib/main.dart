import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/app_theme.dart';
import 'package:tube_sync/app/home_screen.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarDB = Isar.open(
    schemas: [PlaylistSchema, MediaSchema],
    directory: (await getApplicationSupportDirectory()).path,
  );

  runApp(
    MaterialApp(
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
}
