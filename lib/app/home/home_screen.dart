import 'package:flutter/material.dart';
import 'package:tube_sync/app/home/home_tab.dart';

import 'home_app_bar.dart';
import 'home_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: HomeNavigationBar.length,
      child: Scaffold(
        appBar: HomeAppBar(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            HomeTab(),
            Center(child: Text("🤯🤯🤯🤯")),
          ],
        ),
        bottomNavigationBar: HomeNavigationBar(),
      ),
    );
  }
}
