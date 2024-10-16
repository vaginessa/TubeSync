import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MiniPlayerTile extends StatelessWidget {
  final Video video;
  final void Function()? onTap;

  const MiniPlayerTile(this.video, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.only(left: 8, right: 4),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              video.thumbnails.lowResUrl,
            ),
          ),
          titleTextStyle: Theme.of(context).textTheme.bodyMedium,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                video.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                "6/9 \u2022 Music",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          // subtitle:
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          minHeight: 1,
        )
      ],
    );
  }
}
