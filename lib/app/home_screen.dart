import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/library/library_tab.dart';
import 'package:tube_sync/provider/library_provider.dart';

import 'home_app_bar.dart';
import 'home_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: HomeNavigationBar.length,
      child: MultiProvider(
        providers: [
          Provider<GlobalKey<ScaffoldState>>(create: (_) => GlobalKey()),
          ChangeNotifierProvider<LibraryProvider>(
            create: (_) => LibraryProvider(context.read<Isar>()),
          )
        ],
        builder: (context, child) {
          return Scaffold(
            key: Provider.of<GlobalKey<ScaffoldState>>(context),
            appBar: const HomeAppBar(),
            body: child,
            bottomNavigationBar: const HomeNavigationBar(),
          );
        },
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeTab(),
            const Center(child: Text("🤯🤯🤯🤯")),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

  final ValueNotifier<Widget?> notifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      child: LibraryTab(notifier: notifier),
      builder: (context, child, root) {
        return Stack(
          children: [
            Offstage(offstage: child != null, child: root),
            if (child != null) child,
          ],
        );
      },
    );
  }
}
