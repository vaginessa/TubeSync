import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/mini_player_tile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerSheet extends StatefulWidget {
  final Video? initialVideo;

  const PlayerSheet({super.key, this.initialVideo});

  @override
  State<PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<PlayerSheet> {
  final ytClient = YoutubeExplode().videos.streamsClient;
  final player = AudioPlayer(playerId: "AudioPlayerNoDuplicate");
  final controller = DraggableScrollableController();
  late final ValueNotifier<Video> nowPlaying;

  //Workaround for https://github.com/bluefireteam/audioplayers/issues/361
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  // Reference queued beginPlay calls to cancel upon changes
  CancelableOperation? playerQueue;

  Future<void> beginPlay() async {
    buffering.value = true;
    if (mounted) await player.pause();
    final videoManifest = await ytClient.getManifest(nowPlaying.value.id);
    final streamUri = videoManifest.audioOnly.withHighestBitrate().url;
    final source = UrlSource(streamUri.toString());
    if (mounted) await player.setSource(source);
    buffering.value = false;
    if (mounted) await player.resume();
  }

  @override
  void initState() {
    super.initState();
    nowPlaying = ValueNotifier(widget.initialVideo ?? playlist(context).first);
    nowPlaying.addListener(() async {
      await playerQueue?.cancel();
      playerQueue = CancelableOperation.fromFuture(beginPlay());
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    controller.dispose();
    nowPlaying.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 1,
      expand: false,
      snap: true,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return MultiProvider(
          providers: [
            Provider(create: (_) => player),
            ValueListenableProvider<Video>.value(value: nowPlaying),
            ValueListenableProvider<bool>.value(value: buffering),
          ],
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              MiniPlayerTile(
                onTap: expand,
                onPrevious: previousTrack,
                onNext: nextTrack,
                onClose: closePlayer,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Video> playlist(BuildContext context) => context.read<List<Video>>();

  void previousTrack() {
    final currentIndex = playlist(context).indexOf(nowPlaying.value);
    if (currentIndex == 0) return;
    nowPlaying.value = playlist(context)[currentIndex - 1];
  }

  void nextTrack() {
    final currentIndex = playlist(context).indexOf(nowPlaying.value);
    if (currentIndex + 1 == playlist(context).length) return;
    nowPlaying.value = playlist(context)[currentIndex + 1];
  }

  bool get isExpanded => controller.isAttached && controller.size == 1;

  void expand() => controller.animateTo(1.0,
      duration: Durations.medium1, curve: Curves.easeOut);

  void closePlayer() {
    playerQueue?.cancel();
    player.release();
    Navigator.of(context).pop();
  }
}
