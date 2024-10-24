import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: systemOverlayStyle(context),
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset("tubesync.png"),
      ),
      titleSpacing: 0,
      title: const Text("TubeSync"),
      actions: [
        CircleAvatar(
          radius: 16,
          child: Icon(Icons.person_rounded),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  SystemUiOverlayStyle? systemOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.appBarTheme.systemOverlayStyle?.copyWith(
      systemNavigationBarColor: theme.colorScheme.surfaceContainer,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
