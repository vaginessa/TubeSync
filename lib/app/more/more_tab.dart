import 'package:flutter/material.dart';
import 'package:tube_sync/app/more/downloads/active_downloads_screen.dart';

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
        Image.asset("tubesync.png", height: 80),
        SizedBox(height: 16),
        Divider(),
        SwitchListTile(
          value: false,
          onChanged: (value) {},
          secondary: Icon(Icons.palette_rounded),
          title: Text("Material You"),
          subtitle: Text("Use dynamic colors"),
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
          onTap: () {},
          leading: Icon(Icons.info_rounded),
          title: Text("About"),
        ),
      ],
    );
  }
}
