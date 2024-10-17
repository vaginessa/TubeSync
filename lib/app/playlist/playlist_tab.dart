import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/player_sheet.dart';
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
      final vids = await ytClient.getVideos(widget.playlist.id.value).toList();
      videos.clear();
      videos.addAll(vids);
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
          child: MultiProvider(
            providers: [
              Provider(create: (context) => widget.playlist),
              Provider(create: (context) => videos),
            ],
            child: ListView.builder(
              itemCount: videos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return PlaylistHeader(onPlayAll: () => launchPlayer());
                }
                return VideoEntryBuilder(
                  videos[index - 1],
                  onTap: () => launchPlayer(initialVideo: videos[index - 1]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void launchPlayer({Video? initialVideo}) {
    scaffold(context)?.showBottomSheet(
      (_) => MultiProvider(
        providers: [
          Provider<List<Video>>(
            create: (_) => videos,
          ),
          Provider<Playlist>(
            create: (_) => widget.playlist,
          ),
        ],
        child: PlayerSheet(initialVideo: initialVideo),
      ),
      enableDrag: false,
      shape: InputBorder.none,
      elevation: 0,
    );
  }

  ScaffoldState? scaffold(BuildContext context) =>
      context.read<GlobalKey<ScaffoldState>>().currentState;

  @override
  bool get wantKeepAlive => true;
}
