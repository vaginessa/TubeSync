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
          icon: Icon(Icons.my_library_music_outlined),
          selectedIcon: Icon(Icons.my_library_music_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_rounded),
          label: 'More',
        )
      ],
    );
  }
}
