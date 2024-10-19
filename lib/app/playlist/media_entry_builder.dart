import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/model/media.dart';

class MediaEntryBuilder extends StatelessWidget {
  final Media media;
  final void Function()? onTap;

  const MediaEntryBuilder(this.media, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              width: 80,
              imageUrl: media.thumbnail.low,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                videoDuration(media.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
      title: Text(
        media.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      titleTextStyle: Theme.of(context).textTheme.titleSmall,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              const WidgetSpan(
                child: Icon(Icons.download_for_offline_rounded, size: 16),
              ),
              TextSpan(text: " ${media.author}"),
            ]),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert_rounded, size: 18),
      ),
    );
  }

  String videoDuration(Duration? d) {
    if (d == null) return " ??:?? ";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    final hour = twoDigits(d.inHours);
    return " ${hour == '00' ? '' : '$hour:'}$twoDigitMinutes:$twoDigitSeconds ";
  }
}
