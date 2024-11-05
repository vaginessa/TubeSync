import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/model/media.dart';

class Artwork extends StatelessWidget {
  final Media media;
  final Duration duration;

  const Artwork({super.key, required this.media, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Transform.rotate(
        angle: duration.inMilliseconds / 10000,
        child: CircleAvatar(
          maxRadius: 120,
          minRadius: 50,
          backgroundImage: CachedNetworkImageProvider(
            media.thumbnail.high,
          ),
          child: Icon(
            Icons.circle,
            size: 32,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
