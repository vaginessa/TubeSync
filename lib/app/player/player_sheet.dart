import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/mini_player_tile.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/media_provider.dart';

class PlayerSheet extends StatefulWidget {
  final Media? initialMedia;

  const PlayerSheet({super.key, this.initialMedia});

  @override
  State<PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<PlayerSheet> {
  final player = AudioPlayer(playerId: "AudioPlayerNoDuplicate");
  final controller = DraggableScrollableController();

  //Workaround for https://github.com/bluefireteam/audioplayers/issues/361
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  // Reference queued beginPlay calls to cancel upon changes
  CancelableOperation? playerQueue;

  Future<void> beginPlay() async {
    try {
      buffering.value = true;
      if (mounted) await player.pause();

      if (mounted) {
        final source = await mediaProvider(context).getMedia();
        await player.setSource(source);
      }

      if (mounted) await player.resume();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    } finally {
      buffering.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    playerQueue = CancelableOperation.fromFuture(beginPlay());
    mediaProvider(context).nowPlayingNotifier.addListener(() async {
      await playerQueue?.cancel();
      playerQueue = CancelableOperation.fromFuture(beginPlay());
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
    controller.dispose();
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
            Provider<AudioPlayer>(create: (_) => player),
            ValueListenableProvider<bool>.value(value: buffering),
          ],
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              MiniPlayerTile(
                onTap: expand,
                onPrevious: context.read<MediaProvider>().previousTrack,
                onNext: context.read<MediaProvider>().nextTrack,
                onClose: closePlayer,
              ),
            ],
          ),
        );
      },
    );
  }

  MediaProvider mediaProvider(BuildContext context) =>
      context.read<MediaProvider>();

  bool get isExpanded => controller.isAttached && controller.size == 1;

  void expand() => controller.animateTo(1.0,
      duration: Durations.medium1, curve: Curves.easeOut);

  void closePlayer() {
    playerQueue?.cancel();
    player.release();
    Navigator.of(context).pop();
  }
}
