import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/library/library_menu_sheet.dart';
import 'package:tube_sync/model/playlist.dart';
import 'package:tube_sync/provider/library_provider.dart';

class LibraryEntryBuilder extends StatelessWidget {
  final Playlist playlist;
  final void Function()? onTap;

  const LibraryEntryBuilder(this.playlist, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: Hero(
          tag: playlist.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              width: 80,
              imageUrl: playlist.thumbnail.low,
              fit: BoxFit.none,
            ),
          ),
        ),
        title: Text(
          playlist.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        subtitle: Text(
          "${playlist.author} \u2022 ${playlist.videoCount} videos",
        ),
        trailing: IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            useSafeArea: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<LibraryProvider>(),
              child: LibraryMenuSheet(playlist),
            ),
          ),
          icon: const Icon(Icons.more_vert_rounded, size: 18),
        ),
      ),
    );
  }
}
