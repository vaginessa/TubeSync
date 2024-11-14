import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/more/about_screen.dart';
import 'package:tubesync/app/more/downloads/active_downloads_screen.dart';
import 'package:tubesync/model/preferences.dart';

class MoreTab extends StatelessWidget {
  MoreTab({super.key});

  final homeNavigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: NavigatorPopHandler(
        onPop: () => homeNavigator.currentState?.pop(),
        child: Navigator(
          key: homeNavigator,
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => moreTabContent(context),
          ),
        ),
      ),
    );
  }

  Widget moreTabContent(BuildContext context) {
    return ListView(
      children: [
        // BigAss Branding
        SizedBox(height: 8),
        Hero(
          tag: "branding",
          child: Image.asset(
            "assets/tubesync.png",
            height: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 16),
        Divider(),
        ValueListenableBuilder(
          valueListenable: AppTheme.dynamicColors,
          builder: (_, value, __) => SwitchListTile(
            value: value == true,
            onChanged: (value) {
              AppTheme.dynamicColors.value = value;
              context.read<Isar>().preferences.setValue(
                    Preference.materialYou,
                    value,
                  );
            },
            secondary: Icon(Icons.palette_rounded),
            title: Text("Material You"),
            subtitle: Text("Use dynamic colors"),
          ),
        ),
        Divider(),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActiveDownloadsScreen()),
          ),
          leading: Icon(Icons.download_rounded),
          title: Text("Download Queue"),
          subtitle: Text("Manage running downloads"),
        ),
        Divider(),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutScreen()),
          ),
          leading: Icon(Icons.info_rounded),
          title: Text("About"),
        ),
      ],
    );
  }
}
