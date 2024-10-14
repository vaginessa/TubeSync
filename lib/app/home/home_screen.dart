import 'package:flutter/material.dart';
import 'package:tube_sync/app/home/library_tab.dart';

import 'home_app_bar.dart';
import 'home_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: HomeNavigationBar.length,
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeTab(),
            const Center(child: Text("🤯🤯🤯🤯")),
          ],
        ),
        bottomNavigationBar: const HomeNavigationBar(),
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
