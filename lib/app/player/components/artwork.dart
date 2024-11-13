import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/extensions.dart';
import 'package:tube_sync/provider/player_provider.dart';
import 'package:tube_sync/services/media_service.dart';

class Artwork extends StatelessWidget {
  const Artwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ValueListenableBuilder(
        valueListenable: context.read<PlayerProvider>().nowPlaying,
        builder: (context, media, child) => StreamBuilder(
          stream: context.read<PlayerProvider>().player.positionStream,
          initialData: context.read<PlayerProvider>().player.position,
          builder: (context, position) {
            // Modulo by 360 degree / 6.28 rad so the angle doesn't get too large
            final angle = (position.requireData.inMilliseconds / 30000) % 6.28;
            return Transform.rotate(
              angle: angle.toPrecision(3),
              child: CircleAvatar(
                maxRadius: 120,
                minRadius: 50,
                backgroundImage: NetworkToFileImage(
                  url: media.thumbnail.high,
                  file: MediaService().thumbnailFile(media.thumbnail.high),
                ),
                child: Icon(
                  Icons.circle,
                  size: 48,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
