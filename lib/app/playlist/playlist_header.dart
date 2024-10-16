import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({super.key, required this.onPlayAllInvoked});

  Playlist playlist(BuildContext context) => context.read<Playlist>();
  final void Function() onPlayAllInvoked;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: playlist(context).thumbnails.mediumResUrl,
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
                        child: FilledButton.tonalIcon(
                          onPressed: onPlayAllInvoked,
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
            Text(
              playlist(context).title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text("by ${playlist(context).author}"),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
