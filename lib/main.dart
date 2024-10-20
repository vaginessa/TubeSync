import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/home/home_screen.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';

void main() async {
  final isarDB = Isar.open(
    schemas: [PlaylistSchema, MediaSchema],
    directory: (await getApplicationSupportDirectory()).path,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Provider<Isar>(
        create: (context) => isarDB,
        child: const HomeScreen(),
      ),
    ),
  );
}
