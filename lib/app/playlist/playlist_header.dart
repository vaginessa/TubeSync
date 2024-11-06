import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/playlist/playlist_menu_sheet.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

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
            Hero(
              tag: playlist(context).id,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      height: 120,
                      width: double.maxFinite,
                      imageUrl: playlist(context).thumbnail.high,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black38,
                            Colors.black54,
                            Colors.black87,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomLeft,
                          stops: [0, 0.3, 0.6, 0.7, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(left: 8, bottom: 8, child: playlistInfo(context)),
                ],
              ),
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
                    label: const Text(
                      "Play All",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<PlaylistProvider>(),
                      child: PlaylistMenuSheet(),
                    ),
                  ),
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

  Widget playlistInfo(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
        );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(playlist(context).title, style: titleStyle),
        Text(
          "${playlist(context).videoCount} videos \u2022 by ${playlist(context).author}",
          style: bodyStyle,
        ),
      ],
    );
  }

  Playlist playlist(BuildContext context) =>
      context.read<PlaylistProvider>().playlist;
}
