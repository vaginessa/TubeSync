import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/app/playlist/import_playlist_dialog.dart';
import 'package:tube_sync/app/playlist/playlist_entry_builder.dart';
import 'package:tube_sync/app/playlist/playlist_tab.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key, required this.notifier});

  final ValueNotifier<Widget?> notifier;

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with AutomaticKeepAliveClientMixin {
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
            final playlist = entries[index];
            return PlaylistEntryBuilder(playlist, onTap: () {
              widget.notifier.value = PlaylistTab(
                playlist,
                notifier: widget.notifier,
              );
            });
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
          setState(() => entries.add(playlist));
        }),
        label: const Text("Import"),
        icon: const Icon(CupertinoIcons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
