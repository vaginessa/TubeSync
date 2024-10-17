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
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Hero(
          tag: playlist.thumbnails.videoId,
          child: CachedNetworkImage(
            width: 80,
            imageUrl: playlist.thumbnails.lowResUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        playlist.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
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
            "${playlist.author} \u2022 ${playlist.videoCount} videos",
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
