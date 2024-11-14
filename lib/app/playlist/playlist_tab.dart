import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/player/mini_player_sheet.dart';
import 'package:tubesync/app/playlist/media_entry_builder.dart';
import 'package:tubesync/app/playlist/playlist_header.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';
import 'package:tubesync/provider/playlist_provider.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Consumer<PlaylistProvider>(
        child: PlaylistHeader(onPlayAll: () => launchPlayer(context: context)),
        builder: (context, playlist, header) {
          if (AppTheme.isDesktop) {
            return RefreshIndicator(
              onRefresh: playlist.refresh,
              child: Row(
                children: [
                  Flexible(child: header!),
                  Flexible(
                    flex: 2,
                    child: playlistView(context, playlist),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: playlist.refresh,
            child: playlistView(context, playlist, header: header),
          );
        },
      ),
    );
  }

  Widget playlistView(
    BuildContext context,
    PlaylistProvider playlist, {
    Widget? header,
  }) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2),
      itemCount: playlist.medias.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final media = playlist.medias[index - (header != null ? 1 : 0)];
        return MediaEntryBuilder(
          media,
          onTap: () => launchPlayer(context: context, initialMedia: media),
        );
      },
    );
  }

  void launchPlayer({required BuildContext context, Media? initialMedia}) {
    scaffold(context)?.showBottomSheet(
      (_) => Provider<PlayerProvider>(
        create: (_) => PlayerProvider(
          context.read<PlaylistProvider>(),
          start: initialMedia,
        ),
        dispose: (_, provider) => provider.dispose(),
        child: MiniPlayerSheet(),
      ),
      enableDrag: true,
      shape: InputBorder.none,
      elevation: 0,
    );
  }

  ScaffoldState? scaffold(BuildContext context) =>
      context.read<GlobalKey<ScaffoldState>>().currentState;
}
