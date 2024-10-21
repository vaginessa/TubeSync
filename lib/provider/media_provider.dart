import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/playlist_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class MediaProvider {
  final _ytClient = yt.YoutubeExplode().videos.streamsClient;

  final PlaylistProvider playlist;
  late ValueNotifier<Media> nowPlayingNotifier;

  Media get nowPlaying => nowPlayingNotifier.value;

  MediaProvider(this.playlist, Media? initialMedia) {
    nowPlayingNotifier = ValueNotifier(initialMedia ?? playlist.medias.first);
  }

  Future<Source> getMedia() async {
    // Try from offline
    // Fallback to online
    // TODO Skip on no internet
    final videoManifest = await _ytClient.getManifest(nowPlaying.id);
    final streamUri = videoManifest.audioOnly.withHighestBitrate().url;
    final source = UrlSource(streamUri.toString());

    return source;
  }

  void previousTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying);
    if (currentIndex == 0) return;
    nowPlayingNotifier.value = playlist.medias[currentIndex - 1];
  }

  void nextTrack() {
    final currentIndex = playlist.medias.indexOf(nowPlaying);
    if (currentIndex + 1 == playlist.medias.length) return;
    nowPlayingNotifier.value = playlist.medias[currentIndex + 1];
  }

  void dispose() {
    nowPlayingNotifier.dispose();
  }
}
