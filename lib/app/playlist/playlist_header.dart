import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({super.key, required this.onPlayAll});

  final void Function() onPlayAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: playlist(context).thumbnails.videoId,
                  child: SizedBox(
                    height: 120,
                    width: double.maxFinite,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            playlist(context).thumbnails.mediumResUrl,
                          ),
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black26,
                            Colors.black38
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.3, 0.8, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playlist(context).title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        "${playlist(context).videoCount} videos \u2022 by ${playlist(context).author}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onPlayAll,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("Play All"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Playlist playlist(BuildContext context) =>
      context.read<PlaylistProvider>().playlist;
}
