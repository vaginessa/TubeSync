import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({super.key});

  static const int length = 2;

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: DefaultTabController.of(context).index,
      onDestinationSelected: (value) {
        setState(() => DefaultTabController.of(context).animateTo(value));
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(CupertinoIcons.house),
          selectedIcon: Icon(CupertinoIcons.house_fill),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(CupertinoIcons.ellipsis),
          selectedIcon: Icon(CupertinoIcons.ellipsis_circle_fill),
          label: 'More',
        )
      ],
    );
  }
}
