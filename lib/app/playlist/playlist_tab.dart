import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/mini_player_sheet.dart';
import 'package:tube_sync/app/playlist/media_entry_builder.dart';
import 'package:tube_sync/app/playlist/playlist_header.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/player_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Consumer<PlaylistProvider>(
        child: PlaylistHeader(onPlayAll: () => launchPlayer(context: context)),
        builder: (context, playlist, header) => RefreshIndicator(
          onRefresh: playlist.refresh,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2),
            itemCount: playlist.medias.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return header;
              return MediaEntryBuilder(
                playlist.medias[index - 1],
                onTap: () => launchPlayer(
                  context: context,
                  initialMedia: playlist.medias[index - 1],
                ),
              );
            },
          ),
        ),
      ),
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
      enableDrag: false,
      shape: InputBorder.none,
      elevation: 0,
    );
  }

  ScaffoldState? scaffold(BuildContext context) =>
      context.read<GlobalKey<ScaffoldState>>().currentState;
}
