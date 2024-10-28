import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlayerProvider {
  final player = AudioPlayer(playerId: "AudioPlayer");
  final PlaylistProvider playlist;
  late ValueNotifier<Media> nowPlaying;

  //Workaround for https://github.com/bluefireteam/audioplayers/issues/361
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  // Reference queued beginPlay calls to cancel upon changes
  late CancelableOperation? playerQueue;

  PlayerProvider(this.playlist, {Media? start}) {
    nowPlaying = ValueNotifier(start ?? playlist.medias.first);
    playerQueue = CancelableOperation.fromFuture(beginPlay());
    nowPlaying.addListener(() async {
      await playerQueue?.cancel();
      playerQueue = CancelableOperation.fromFuture(beginPlay());
    });

    player.onPlayerComplete.listen((_) => nextTrack());
  }

  Future<void> beginPlay() async {
    try {
      buffering.value = true;
      await player.pause();
      final source = await MediaProvider().getMedia(nowPlaying.value);
      // No internet / broken media. Skip to next
      if (source == null) return nextTrack();

      await player.setSource(source);
      await player.resume();
    } catch (err) {
      //TODO Show error
    } finally {
      buffering.value = false;
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
    buffering.dispose();
    player.dispose();
  }
}
