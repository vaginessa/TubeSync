import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/artwork.dart';
import 'package:tube_sync/app/player/seekbar.dart';
import 'package:tube_sync/extensions.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/player_provider.dart';

class LargePlayerSheet extends StatelessWidget {
  const LargePlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: RotatedBox(
            quarterTurns: -1, // Negative 90 Deg
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: context.read<PlayerProvider>().nowPlaying,
            builder: (context, media, child) {
              return StreamBuilder(
                stream: context.read<PlayerProvider>().player.positionStream,
                initialData: context.read<PlayerProvider>().player.position,
                builder: (context, state) => Artwork(
                  media: media,
                  duration: state.requireData,
                ),
              );
              return ListTile(
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
                trailing: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              );
            },
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
                    if (nowPlaying(context).duration != null)
                      SeekBar(
                        buffering: buffering(context),
                        playing: player(context).playing,
                        duration: nowPlaying(context).duration!,
                        position: currentPosition.requireData,
                        bufferedPosition: player(context).bufferedPosition,
                        onChangeEnd: (v) => player(context).seek(v),
                      ),
                  ],
                ),
              );
            },
          ),

          StreamBuilder(
            stream: player(context).playerStateStream,
            initialData: player(context).playerState,
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: playerProvider(context).hasNoPrevious
                        ? null
                        : playerProvider(context).previousTrack,
                    icon: Icon(Icons.skip_previous_rounded),
                  ),
                  if (buffering(context))
                    CircularProgressIndicator()
                  else if (snapshot.requireData.playing)
                    IconButton(
                      onPressed: () => player(context).pause(),
                      icon: const Icon(Icons.pause_rounded),
                    )
                  else
                    IconButton(
                      onPressed: () => player(context).play(),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  IconButton(
                    onPressed: playerProvider(context).hasNoNext
                        ? null
                        : playerProvider(context).nextTrack,
                    icon: Icon(Icons.skip_next_rounded),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  PlayerProvider playerProvider(BuildContext context) =>
      context.read<PlayerProvider>();

  String playlistInfo(BuildContext context) =>
      "${playlist(context).title} by ${playlist(context).author}";

  String positionInPlaylist(BuildContext context, Media media) {
    return "${videos(context).indexOf(media) + 1}/${playlist(context).videoCount}";
  }

  bool buffering(BuildContext context) {
    return context.read<PlayerProvider>().buffering.value;
  }

  Media nowPlaying(BuildContext context) =>
      playerProvider(context).nowPlaying.value;

  Playlist playlist(BuildContext context) =>
      playerProvider(context).playlist.playlist;

  List<Media> videos(BuildContext context) =>
      playerProvider(context).playlist.medias;

  AudioPlayer player(BuildContext context) => playerProvider(context).player;
}
