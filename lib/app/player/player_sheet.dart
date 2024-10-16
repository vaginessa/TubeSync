import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/app/player/mini_player_tile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerSheet extends StatefulWidget {
  final List<Video> playlist;

  const PlayerSheet(this.playlist, {super.key});

  @override
  State<PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<PlayerSheet> {
  final controller = DraggableScrollableController();
  late Video nowPlaying;

  @override
  void initState() {
    super.initState();
    nowPlaying = widget.playlist.first;
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
        return ListView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          children: [
            Dismissible(
              key: const Key("MiniPlayer"),
              confirmDismiss: (direction) {

                return Future.value(false);
              },
              direction: DismissDirection.horizontal,
              background: const Row(
                children: [
                  SizedBox(width: 18),
                  Icon(Icons.skip_previous_rounded),
                ],
              ),
              secondaryBackground: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.skip_next_rounded),
                  SizedBox(width: 18),
                ],
              ),
              dismissThresholds: const {DismissDirection.horizontal: 0.3},
              child: MiniPlayerTile(nowPlaying, onTap: expand),
            ),
          ],
        );
      },
    );
  }

  bool get isExpanded => controller.isAttached && controller.size == 1;

  void expand() => controller.animateTo(1.0,
      duration: Durations.medium1, curve: Curves.easeOut);
}
