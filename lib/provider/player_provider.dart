import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
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

  // Buffering state because we fetch Uri on demand
  final ValueNotifier<bool> buffering = ValueNotifier(false);

  ValueNotifier<Media> get nowPlaying => _nowPlaying;

  PlayerProvider(this.playlist, {Media? start}) {
    _nowPlaying = ValueNotifier(start ?? playlist.medias.first);
    nowPlaying.addListener(beginPlay);
    beginPlay();

    MediaService().bind(
      player: player,
      nextTrackCallback: nextTrack,
      previousTrackCallback: previousTrack,
    );

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) nextTrack();
    });

    player.positionStream.listen(
      (position) => notificationState?.add(notificationState!.value.copyWith(
        updatePosition: position,
        bufferedPosition: player.bufferedPosition,
      )),
    );

    player.playerStateStream.listen(
      (state) => notificationState?.add(notificationState!.value.copyWith(
        playing: state.playing,
        processingState: buffering.value
            ? AudioProcessingState.loading
            : AudioProcessingState.values.byName(state.processingState.name),
        controls: [
          if (!hasNoPrevious) MediaControl.skipToPrevious,
          if (!hasNoNext) MediaControl.skipToNext,
          if (!buffering.value) MediaControl.rewind,
          if (!buffering.value) MediaControl.fastForward,
        ],
        systemActions: {
          if (!hasNoPrevious) MediaAction.skipToPrevious,
          if (!hasNoNext) MediaAction.skipToNext,
          if (!buffering.value) MediaAction.seek,
          if (!buffering.value) MediaAction.rewind,
          if (!buffering.value) MediaAction.fastForward,
        },
      )),
    );
  }

  Future<void> beginPlay() async {
    final media = nowPlaying.value;
    try {
      buffering.value = true;
      await player.stop();
      await player.seek(Duration.zero);

      final thumbnail = MediaService().thumbnailFile(
        nowPlaying.value.thumbnail.medium,
      );

      var artUri = Uri.parse(nowPlaying.value.thumbnail.medium);
      if (thumbnail.existsSync()) artUri = thumbnail.uri;

      // Post service notification update
      notificationMetadata?.add(MediaItem(
        id: nowPlaying.value.id,
        title: nowPlaying.value.title,
        artist: nowPlaying.value.author,
        duration: nowPlaying.value.duration,
        album: playlist.playlist.title,
        artUri: artUri,
      ));

      notificationState?.add(notificationState!.value.copyWith(
        processingState: AudioProcessingState.loading,
        playing: false,
        updatePosition: Duration.zero,
      ));

      final source = await MediaService().getMediaSource(media);

      if (media != nowPlaying.value) return;
      await player.setAudioSource(source);

      if (_disposed) return;
      // Don't await this. Ever.
      // Fuck. I wasted whole day on this
      player.play();
      buffering.value = false;
    } catch (err) {
      if (_disposed) return;
      if (media != nowPlaying.value) return;
      nextTrack();
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
    nowPlaying.dispose();
    buffering.dispose();
    player.stop().whenComplete(player.dispose);
    MediaService().unbind(player);
  }

  BehaviorSubject<PlaybackState>? get notificationState {
    if (_disposed) return null;
    return MediaService().playbackState;
  }

  BehaviorSubject<MediaItem?>? get notificationMetadata {
    if (_disposed) return null;
    return MediaService().mediaItem;
  }
}
