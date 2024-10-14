import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/app/playlist/import_playlist_dialog.dart';
import 'package:tube_sync/app/playlist/playlist_entry_builder.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final List<Playlist> entries = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      primary: false,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return PlaylistEntryBuilder(entries[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<Playlist?>(
          context: context,
          builder: (context) => const ImportPlaylistDialog(),
        ).then((playlist) {
          if (playlist == null) return;
          if (entries.contains(playlist)) return;
          entries.add(playlist);
          setState(() {});
        }),
        label: const Text("Import"),
        icon: const Icon(CupertinoIcons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
