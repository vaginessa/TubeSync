import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../home/home_screen.dart';
import '../player/player_sheet.dart';

class PlaylistHeader extends StatelessWidget {
  final Playlist playlist;
  final List<Video> videos;

  const PlaylistHeader(this.playlist, {super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: playlist.thumbnails.mediumResUrl,
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            rootScaffold.currentState?.showBottomSheet(
                              (context) => PlayerSheet(videos),
                              enableDrag: false,
                              shape: InputBorder.none,
                              elevation: 0,
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text("Play All"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.maybePop(context),
                        visualDensity: VisualDensity.comfortable,
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(playlist.title, style: Theme.of(context).textTheme.titleLarge),
            Text("by ${playlist.author}"),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
