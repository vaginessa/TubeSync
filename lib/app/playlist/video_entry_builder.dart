import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoEntryBuilder extends StatelessWidget {
  final Video video;
  final void Function()? onTap;

  const VideoEntryBuilder(this.video, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          width: 80,
          imageUrl: video.thumbnails.mediumResUrl,
        ),
      ),
      title: Text(
        video.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (video.description.isNotEmpty)
            Text(
              video.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text("${video.author} \u2022 ${video.engagement.viewCount} views"),
        ],
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
      ),
    );
  }
}
