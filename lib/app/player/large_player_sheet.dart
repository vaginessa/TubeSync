import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/components/artwork.dart';
import 'package:tube_sync/app/player/components/seekbar.dart';
import 'package:tube_sync/extensions.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/player_provider.dart';

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
            builder: (context, media, child) {
              return Card.outlined(
                elevation: 0,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  onTap: () {},
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
