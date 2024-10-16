import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MiniPlayerTile extends StatelessWidget {
  final Video video;
  final void Function()? onTap;
  final void Function()? onClose;
  final void Function(Video video)? onTrackChange;

  const MiniPlayerTile(
    this.video, {
    super.key,
    this.onTap,
    this.onClose,
    this.onTrackChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key("MiniPlayer"),
      confirmDismiss: (direction) {
        // todo prev next
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
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.only(left: 8, right: 4),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                video.thumbnails.lowResUrl,
              ),
            ),
            titleTextStyle: Theme.of(context).textTheme.bodyMedium,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  video.author,
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
                      else
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
            builder: (context, snapshot) {
              return LinearProgressIndicator(
                minHeight: 1,
                value: playerProgress(snapshot),
              );
            },
          )
        ],
      ),
    );
  }

  double? playerProgress(AsyncSnapshot<Duration> snapshot) {
    if (!snapshot.hasData || video.duration == null) return null;
    return snapshot.requireData.inMilliseconds / video.duration!.inMilliseconds;
  }

  String playlistInfo(BuildContext context) =>
      "${context.read<Playlist>().title} by ${context.read<Playlist>().author}";

  String positionInPlaylist(BuildContext context) =>
      "${context.read<List<Video>>().indexOf(video) + 1}/${context.read<Playlist>().videoCount}";

  AudioPlayer player(BuildContext context) => context.read<AudioPlayer>();
}
