import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Icon(CupertinoIcons.music_note_list),
      titleSpacing: 0,
      title: const Text("TubeSync"),
      actions: const [
        CircleAvatar(
          radius: 16,
          child: Icon(CupertinoIcons.person),
        ),
        SizedBox(width: 12)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
