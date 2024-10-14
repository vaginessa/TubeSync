import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistEntryBuilder extends StatelessWidget {
  final Playlist playlist;

  const PlaylistEntryBuilder(this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          width: 80,
          imageUrl: playlist.thumbnails.maxResUrl,
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
          Row(
            children: [
              Text("${playlist.videoCount} videos"),
              const Text(" \u2022 "),
              Text("${playlist.engagement.viewCount} views"),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(CupertinoIcons.ellipsis_vertical, size: 18),
      ),
    );
  }
}
