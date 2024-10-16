import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MiniPlayerTile extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onPrevious;
  final void Function()? onNext;
  final void Function()? onClose;

  const MiniPlayerTile({
    super.key,
    this.onTap,
    this.onPrevious,
    this.onNext,
    this.onClose,
  });

  Video video(BuildContext context) => context.watch<Video>();

  bool buffering(BuildContext context) => context.watch<bool>();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key("MiniPlayer"),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) onPrevious?.call();
        if (direction == DismissDirection.endToStart) onNext?.call();
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
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2,
      },
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.only(left: 8, right: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(
                video(context).thumbnails.lowResUrl,
              ),
            ),
            titleTextStyle: Theme.of(context).textTheme.bodyMedium,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video(context).title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  video(context).author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "${positionInPlaylist(context)} \u2022 ${playlistInfo(context)}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            //Some Actions
            trailing: StreamBuilder(
              stream: player(context).onPlayerStateChanged,
              builder: (context, snapshot) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snapshot.hasData) ...{
                      if (snapshot.requireData == PlayerState.playing)
                        IconButton(
                          onPressed: () => player(context).pause(),
                          icon: const Icon(Icons.pause_rounded),
                        )
                      else if (!buffering(context))
                        IconButton(
                          onPressed: () => player(context).resume(),
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                    },
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                );
              },
            ),
          ),
          // Progress Indicator
          StreamBuilder<Duration>(
            stream: player(context).onPositionChanged,
            builder: (context, snapshot) => LinearProgressIndicator(
              minHeight: 1,
              value: playerProgress(context, snapshot),
            ),
          )
        ],
      ),
    );
  }

  double? playerProgress(
    BuildContext context,
    AsyncSnapshot<Duration> snapshot,
  ) {
    if (buffering(context) || !snapshot.hasData) return null;
    final vid = video(context);
    if (vid.duration == null) return null;
    return snapshot.requireData.inMilliseconds / vid.duration!.inMilliseconds;
  }

  String playlistInfo(BuildContext context) =>
      "${context.read<Playlist>().title} by ${context.read<Playlist>().author}";

  String positionInPlaylist(BuildContext context) =>
      "${context.read<List<Video>>().indexOf(video(context)) + 1}/${context.read<Playlist>().videoCount}";

  AudioPlayer player(BuildContext context) => context.read<AudioPlayer>();
}
