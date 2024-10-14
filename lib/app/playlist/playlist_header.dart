import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistHeader extends StatelessWidget {
  final Playlist playlist;

  const PlaylistHeader(this.playlist, {super.key});

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
                  left: 2,
                  top: 2,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(CupertinoIcons.back),
                  ),
                ),
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
