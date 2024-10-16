import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistEntryBuilder extends StatelessWidget {
  final Playlist playlist;
  final void Function()? onTap;

  const PlaylistEntryBuilder(this.playlist, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          width: 80,
          imageUrl: playlist.thumbnails.lowResUrl,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        playlist.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (playlist.description.isNotEmpty)
            Text(
              playlist.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            "${playlist.videoCount} videos \u2022 ${playlist.engagement.viewCount} views",
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
      ),
    );
  }
}
