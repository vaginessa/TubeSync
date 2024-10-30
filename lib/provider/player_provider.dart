import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// ignore: depend_on_referenced_packages Just for Types. Doesn't matter
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/playlist_provider.dart';
import 'package:tube_sync/services/media_service.dart';

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
    MediaService().bind(
      player: player,
      nextTrackCallback: nextTrack,
      previousTrackCallback: previousTrack,
    );
    _nowPlaying = ValueNotifier(start ?? playlist.medias.first);
    _playerQueue = CancelableOperation.fromFuture(beginPlay());
    nowPlaying.addListener(() async {
      await _playerQueue?.cancel();
      _playerQueue = CancelableOperation.fromFuture(beginPlay());
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) nextTrack();
    });

    player.positionStream.listen(
      (position) => notificationState.add(notificationState.value.copyWith(
        updatePosition: position,
        bufferedPosition: player.bufferedPosition,
      )),
    );

    player.playerStateStream.listen(
      (state) => notificationState.add(notificationState.value.copyWith(
        playing: state.playing,
        processingState: buffering.value
            ? AudioProcessingState.loading
            : AudioProcessingState.values.byName(state.processingState.name),
        controls: [
          if (!hasNoPrevious) MediaControl.skipToPrevious,
          if (!buffering.value) MediaControl.rewind,
          if (!buffering.value) MediaControl.fastForward,
          if (!hasNoNext) MediaControl.skipToNext,
        ],
        systemActions: {
          if (!buffering.value) MediaAction.seek,
          MediaAction.rewind,
          MediaAction.fastForward,
        },
      )),
    );
  }

  Future<void> beginPlay() async {
    try {
      buffering.value = true;
      await player.pause();
      await player.seek(Duration.zero);

      // Post service notification update
      notificationMetadata.add(MediaItem(
        id: nowPlaying.value.id,
        title: nowPlaying.value.title,
        artist: nowPlaying.value.author,
        duration: nowPlaying.value.duration,
        album: playlist.playlist.title,
        artUri: Uri.parse(nowPlaying.value.thumbnail.medium),
      ));

      notificationState.add(notificationState.value.copyWith(
        processingState: AudioProcessingState.loading,
        playing: player.playing,
      ));

      await player.setAudioSource(
        await MediaService().getMedia(nowPlaying.value),
      );

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      buffering.value = false;
    } catch (err) {
      if (err is HttpException) nextTrack();
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

  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _playerQueue?.cancel();
    nowPlaying.dispose();
    buffering.dispose();
    player.stop().whenComplete(player.dispose);
    MediaService().unbind();
  }

  BehaviorSubject<PlaybackState> get notificationState =>
      MediaService().playbackState;

  BehaviorSubject<MediaItem?> get notificationMetadata =>
      MediaService().mediaItem;
}
