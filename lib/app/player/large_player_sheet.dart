import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/player/components/artwork.dart';
import 'package:tubesync/app/player/components/seekbar.dart';
import 'package:tubesync/extensions.dart';
import 'package:tubesync/model/media.dart';
import 'package:tubesync/provider/player_provider.dart';

class LargePlayerSheet extends StatefulWidget {
  const LargePlayerSheet({super.key});

  @override
  State<LargePlayerSheet> createState() => _LargePlayerSheetState();
}

class _LargePlayerSheetState extends State<LargePlayerSheet>
    with TickerProviderStateMixin {
  late final tabController = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

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
        title: Image.asset(
          "assets/tubesync.png",
          height: 30,
          fit: BoxFit.contain,
          color: Theme.of(context).colorScheme.primary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Music'),
                icon: Icon(Icons.art_track_rounded),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Lyrics'),
                icon: Icon(Icons.lyrics_rounded),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Video'),
                icon: Icon(Icons.play_circle_fill_rounded),
              ),
            ],
            showSelectedIcon: false,
            selected: {tabController.index},
            onSelectionChanged: (value) => setState(
              () => tabController.animateTo(value.first),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Artwork(),
                Center(child: Text("Soon")),
                Center(child: Text("Soon")),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: context.read<PlayerProvider>().nowPlaying,
            builder: (context, media, _) {
              return Card.outlined(
                elevation: 0,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  onTap: () => showPlayerQueue(context),
                  title: Text(
                    media.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        media.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${positionInPlaylist(context, media)} \u2022 ${playlistInfo(context)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  leading: Icon(Icons.playlist_play_rounded),
                  trailing: Icon(Icons.keyboard_arrow_right_rounded),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          // SeekBar
          ValueListenableBuilder(
            valueListenable: context.read<PlayerProvider>().nowPlaying,
            builder: (context, media, _) => StreamBuilder<Duration>(
              stream: context.read<PlayerProvider>().player.positionStream,
              builder: (context, currentPosition) => Padding(
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
                        Text(media.duration.formatHHMM()),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: context.read<PlayerProvider>().buffering,
                      builder: (context, buffering, child) {
                        if (media.duration == null) return SizedBox();
                        final player = context.read<PlayerProvider>().player;
                        final position = currentPosition.data ?? Duration.zero;
                        return SeekBar(
                          buffering: buffering,
                          duration: media.duration!,
                          position: position,
                          bufferedPosition: player.bufferedPosition,
                          onChangeEnd: (v) => player.seek(v),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          StreamBuilder(
            stream: context.read<PlayerProvider>().player.playerStateStream,
            initialData: context.read<PlayerProvider>().player.playerState,
            builder: (context, playerState) {
              final player = context.read<PlayerProvider>();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: player.hasPrevious ? player.previousTrack : null,
                    icon: Icon(Icons.skip_previous_rounded),
                  ),
                  ValueListenableBuilder(
                    valueListenable: context.read<PlayerProvider>().buffering,
                    builder: (context, buffering, loading) {
                      if (buffering) return loading!;
                      if (playerState.requireData.playing) {
                        return IconButton(
                          onPressed: player.player.pause,
                          icon: const Icon(Icons.pause_rounded),
                        );
                      }
                      return IconButton(
                        onPressed: player.player.play,
                        icon: const Icon(Icons.play_arrow_rounded),
                      );
                    },
                    child: const CircularProgressIndicator(),
                  ),
                  IconButton(
                    onPressed: player.hasNext ? player.nextTrack : null,
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

  void showPlayerQueue(BuildContext context) {
    //
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
