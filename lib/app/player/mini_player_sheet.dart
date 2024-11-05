import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/expanded_player_sheet.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/player_provider.dart';

class MiniPlayerSheet extends StatelessWidget {
  const MiniPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key("MiniPlayer"),
      confirmDismiss: (direction) {
        switch (direction) {
          case DismissDirection.startToEnd:
            context.read<PlayerProvider>().previousTrack();
            return Future.value(false);

          case DismissDirection.endToStart:
            context.read<PlayerProvider>().nextTrack();
            return Future.value(false);

          default:
            return Future.value(false);
        }
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
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2,
      },
      child: ValueListenableBuilder(
        key: ValueKey("NowPlaying"),
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder: (context, nowPlaying, _) {
          return Column(
            key: ValueKey(nowPlaying.hashCode),
            mainAxisSize: MainAxisSize.min,
            children: [
              mediaDetails(context, nowPlaying),
              // Progress Indicator
              ValueListenableBuilder(
                valueListenable: context.read<PlayerProvider>().buffering,
                builder: (_, buffering, progressIndicator) {
                  if (!buffering) return progressIndicator!;
                  return const LinearProgressIndicator(minHeight: 1);
                },
                child: StreamBuilder<Duration>(
                  stream: context.read<PlayerProvider>().player.positionStream,
                  builder: (context, snapshot) {
                    final duration = nowPlaying.durationMs;
                    var progress = (duration != null && snapshot.hasData)
                        ? snapshot.requireData.inMilliseconds / duration
                        : null;
                    return LinearProgressIndicator(
                      minHeight: 1,
                      value: progress,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget mediaDetails(BuildContext context, Media media) {
    return ListTile(
      onTap: () => openPlayerSheet(context),
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(
          media.thumbnail.medium,
        ),
      ),
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            media.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            "${positionInPlaylist(context, media)} \u2022 ${playlistInfo(context)}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      //Player Actions
      trailing: actions(context),
    );
  }

  Widget actions(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<PlayerProvider>().buffering,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded),
      ),
      builder: (context, buffering, closeButton) {
        if (buffering) return closeButton!;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder(
              stream: context.read<PlayerProvider>().player.playerStateStream,
              builder: (context, state) {
                if (state.data?.playing == true) {
                  return IconButton(
                    onPressed: context.read<PlayerProvider>().player.pause,
                    icon: const Icon(Icons.pause_rounded),
                  );
                }
                return IconButton(
                  onPressed: context.read<PlayerProvider>().player.play,
                  icon: const Icon(Icons.play_arrow_rounded),
                );
              },
            ),
            closeButton!
          ],
        );
      },
    );
  }

  void openPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => Provider<PlayerProvider>.value(
        value: context.read<PlayerProvider>(),
        child: ExpandedPlayerSheet(),
      ),
    );
  }

  String playlistInfo(BuildContext context) {
    final playlist = context.read<PlayerProvider>().playlist.playlist;
    return "${playlist.title} by ${playlist.author}";
  }

  String positionInPlaylist(BuildContext context, Media media) {
    final medias = context.read<PlayerProvider>().playlist.medias;
    return "${medias.indexOf(media) + 1}/${medias.length}";
  }
}
