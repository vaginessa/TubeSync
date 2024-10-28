import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/extensions.dart';
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
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: playerProvider(context).nowPlaying,
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
            trailing: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ),
        ),
        // SeekBar
        StreamBuilder<Duration>(
          stream: player(context).positionStream,
          initialData: player(context).position,
          builder: (context, currentPosition) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(currentPosition.data.formatHHMM()),
                      Spacer(),
                      Text(nowPlaying(context).duration.formatHHMM()),
                    ],
                  ),
                  Slider(
                    onChanged: (value) => player(context).seek(
                      Duration(seconds: value.toInt()),
                    ),
                    max: nowPlaying(context).duration!.inSeconds.toDouble(),
                    value: currentPosition.requireData.inSeconds.toDouble(),
                  ),
                ],
              ),
            );
          },
        ),

        StreamBuilder(
          stream: player(context).playerStateStream,
          initialData: player(context).playerState,
          builder: (context, snapshot) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: playerProvider(context).hasNoPrevious
                    ? null
                    : playerProvider(context).previousTrack,
                icon: Icon(Icons.skip_previous_rounded),
              ),
              if (snapshot.requireData.playing)
                IconButton(
                  onPressed: () => player(context).pause(),
                  icon: const Icon(Icons.pause_rounded),
                )
              else ...{
                switch (snapshot.requireData.processingState) {
                  ProcessingState.loading => CircularProgressIndicator(),
                  ProcessingState.buffering => CircularProgressIndicator(),
                  _ => IconButton(
                      onPressed: () => player(context).play(),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                }
              },
              IconButton(
                onPressed: playerProvider(context).hasNoNext
                    ? null
                    : playerProvider(context).nextTrack,
                icon: Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  PlayerProvider playerProvider(BuildContext context) =>
      context.read<PlayerProvider>();

  String playlistInfo(BuildContext context) =>
      "${playlist(context).title} by ${playlist(context).author}";

  String positionInPlaylist(BuildContext context, Media media) {
    return "${videos(context).indexOf(media) + 1}/${playlist(context).videoCount}";
  }

  Media nowPlaying(BuildContext context) =>
      playerProvider(context).nowPlaying.value;

  Playlist playlist(BuildContext context) =>
      playerProvider(context).playlist.playlist;

  List<Media> videos(BuildContext context) =>
      playerProvider(context).playlist.medias;

  AudioPlayer player(BuildContext context) => playerProvider(context).player;
}
