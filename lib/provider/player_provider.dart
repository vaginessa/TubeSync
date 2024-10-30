import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/media_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlayerProvider extends BaseAudioHandler {
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

    player.positionStream.listen(
      (position) => playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
        bufferedPosition: player.bufferedPosition,
      )),
    );

    player.playerStateStream.listen(
      (state) => playbackState.add(playbackState.value.copyWith(
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

    AudioService.init(
      builder: () => this,
      config: AudioServiceConfig(
        rewindInterval: Duration(seconds: 5),
        androidNotificationChannelName: 'TubeSync',
        preloadArtwork: true,
      ),
    );
  }

  Future<void> beginPlay() async {
    try {
      buffering.value = true;
      await player.pause();
      await player.seek(Duration.zero);

      // Post service notification update
      mediaItem.add(
        MediaItem(
          id: nowPlaying.value.id,
          title: nowPlaying.value.title,
          artist: nowPlaying.value.author,
          duration: nowPlaying.value.duration,
          album: playlist.playlist.title,
          artUri: Uri.parse(nowPlaying.value.thumbnail.medium),
        ),
      );

      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.loading,
        playing: player.playing,
      ));

      await player.setAudioSource(
        await MediaProvider().getMedia(nowPlaying.value),
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
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToPrevious() async => previousTrack();

  @override
  Future<void> skipToNext() async => nextTrack();

  @override
  Future<void> rewind() => player.seek(player.position - Duration(seconds: 5));

  @override
  Future<void> fastForward() {
    return player.seek(player.position + Duration(seconds: 5));
  }
}
