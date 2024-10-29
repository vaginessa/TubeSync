import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlayerProvider {
  final player = AudioPlayer();
  final PlaylistProvider playlist;

  late ValueNotifier<Media> _nowPlaying;

  // Reference queued beginPlay calls to cancel upon changes
  late CancelableOperation? _playerQueue;

  // Buffering state because we fetch Uri on demand
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  ValueNotifier<Media> get nowPlaying => _nowPlaying;

  PlayerProvider(this.playlist, {Media? start}) {
    _nowPlaying = ValueNotifier(start ?? playlist.medias.first);
    _playerQueue = CancelableOperation.fromFuture(beginPlay());
    nowPlaying.addListener(() async {
      await _playerQueue?.cancel();
      _playerQueue = CancelableOperation.fromFuture(beginPlay());
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) nextTrack();
    });
  }

  Future<void> beginPlay() async {
    try {
      buffering.value = true;
      await player.stop();
      await player.setAudioSource(
        await MediaProvider().getMedia(nowPlaying.value),
      );

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      buffering.value = false;
    } catch (err) {
      //TODO Show error
      if (err is HttpException) nextTrack();
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

  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _playerQueue?.cancel();
    nowPlaying.dispose();
    buffering.dispose();
    player.dispose();
  }
}
