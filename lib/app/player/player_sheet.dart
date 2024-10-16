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
  final player = AudioPlayer();
  final controller = DraggableScrollableController();
  late Video nowPlaying;

  List<Video> playlist(BuildContext context) => context.read<List<Video>>();

  Future<void> beginPlay() async {
    final videoManifest = await ytClient.getManifest(nowPlaying.id);
    // final stream = ytClient.get(videoManifest.audioOnly.withHighestBitrate());
    await player.setSourceUrl(
      videoManifest.audioOnly.withHighestBitrate().url.toString(),
    );

    await player.resume();
  }

  @override
  void initState() {
    super.initState();
    nowPlaying = widget.initialVideo ?? playlist(context).first;
    beginPlay();
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
    player.dispose();
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
        return Provider<AudioPlayer>(
          create: (_) => player,
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              MiniPlayerTile(
                nowPlaying,
                onTap: expand,
                onClose: close,
                onTrackChange: (video) {
                  //
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void close() {
    // context.read<ScaffoldState>().
    Navigator.of(context).pop();
  }

  bool get isExpanded => controller.isAttached && controller.size == 1;

  void expand() => controller.animateTo(1.0,
      duration: Durations.medium1, curve: Curves.easeOut);
}
