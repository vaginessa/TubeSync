import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/player_provider.dart';

class ExpandedPlayerSheet extends StatelessWidget {
  final void Function()? onPrevious;
  final void Function()? onNext;

  const ExpandedPlayerSheet({
    super.key,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: context.read<PlayerProvider>().nowPlaying,
          builder: (context, media, child) => ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(
                media.thumbnail.low,
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
            //Some Actions
            trailing: StreamBuilder(
              stream: player(context).onPlayerStateChanged,
              initialData: player(context).state,
              builder: (context, snapshot) => Row(
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
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Progress Indicator
        FutureBuilder(
          future: player(context).getCurrentPosition(),
          builder: (context, snapshot) => StreamBuilder<Duration>(
            stream: player(context).onPositionChanged,
            initialData: snapshot.data ?? Duration(),
            builder: (context, snapshot) => LinearProgressIndicator(
              minHeight: 1,
              value: playerProgress(context, snapshot),
            ),
          ),
        )
      ],
    );
  }

  double? playerProgress(
    BuildContext context,
    AsyncSnapshot<Duration> snapshot,
  ) {
    if (buffering(context) || !snapshot.hasData) return null;
    final vid = context.read<PlayerProvider>().nowPlaying.value;
    if (vid.durationMs == null) return null;
    return snapshot.requireData.inMilliseconds / vid.durationMs!;
  }

  bool buffering(BuildContext context) =>
      context.read<PlayerProvider>().buffering.value;

  String playlistInfo(BuildContext context) =>
      "${playlist(context).title} by ${playlist(context).author}";

  String positionInPlaylist(BuildContext context, Media media) {
    return "${videos(context).indexOf(media) + 1}/${playlist(context).videoCount}";
  }

  Playlist playlist(BuildContext context) =>
      context.read<PlayerProvider>().playlist.playlist;

  List<Media> videos(BuildContext context) =>
      context.read<PlayerProvider>().playlist.medias;

  AudioPlayer player(BuildContext context) =>
      context.read<PlayerProvider>().player;
}
