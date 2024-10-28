import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlayerProvider {
  final player = AudioPlayer();
  final PlaylistProvider playlist;
  late ValueNotifier<Media> nowPlaying;

  // Reference queued beginPlay calls to cancel upon changes
  late CancelableOperation? playerQueue;

  PlayerProvider(this.playlist, {Media? start}) {
    nowPlaying = ValueNotifier(start ?? playlist.medias.first);
    playerQueue = CancelableOperation.fromFuture(beginPlay());
    nowPlaying.addListener(() async {
      await playerQueue?.cancel();
      playerQueue = CancelableOperation.fromFuture(beginPlay());
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) nextTrack();
    });
  }

  Future<void> beginPlay() async {
    try {
      await player.pause();
      final source = await MediaProvider().getMedia(nowPlaying.value);
      // No internet / broken media. Skip to next
      if (source == null) return nextTrack();

      await player.setAudioSource(source);
      await player.play();
    } catch (err) {
      //TODO Show error
    }
  }

  bool get hasNoPrevious => playlist.medias.indexOf(nowPlaying.value) == 0;

  bool get hasNoNext {
    return playlist.medias.indexOf(nowPlaying.value) + 1 ==
        playlist.medias.length;
  }

  void previousTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying.value);
    if (currentIndex == 0) return;
    nowPlaying.value = playlist.medias[currentIndex - 1];
  }

  void nextTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying.value);
    if (currentIndex + 1 == playlist.medias.length) return;
    nowPlaying.value = playlist.medias[currentIndex + 1];
  }

  void dispose() {
    playerQueue?.cancel();
    nowPlaying.dispose();
    player.dispose();
  }
}
