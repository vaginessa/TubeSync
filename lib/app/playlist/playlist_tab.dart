import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/app/playlist/playlist_header.dart';
import 'package:tube_sync/app/playlist/video_entry_builder.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab(this.playlist, {super.key, required this.notifier});

  final Playlist playlist;
  final ValueNotifier<Widget?> notifier;

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab>
    with AutomaticKeepAliveClientMixin {
  final ytClient = YoutubeExplode().playlists;
  final List<Video> videos = List.empty(growable: true);
  final GlobalKey<RefreshIndicatorState> refreshIndicator = GlobalKey();

  Future<void> refreshHandler() async {
    try {
      videos.addAll(
        await ytClient.getVideos(widget.playlist.id.value).toList(),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshIndicator.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        widget.notifier.value = null;
      },
      child: Scaffold(
        primary: false,
        body: RefreshIndicator(
          key: refreshIndicator,
          onRefresh: refreshHandler,
          child: ListView.builder(
            itemCount: videos.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return PlaylistHeader(widget.playlist);
              return VideoEntryBuilder(videos[index - 1], onTap: () {});
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(CupertinoIcons.play_fill),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
