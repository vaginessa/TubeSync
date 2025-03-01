import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesync/app/more/downloads/active_downloads_screen.dart';
import 'package:tubesync/provider/playlist_provider.dart';
import 'package:tubesync/services/downloader_service.dart';

class PlaylistMenuSheet extends StatelessWidget {
  const PlaylistMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Drag Handle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 4,
              width: kMinInteractiveDimension,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              DownloaderService().downloadAll(
                context.read<PlaylistProvider>().medias,
              );
              ActiveDownloadsScreen.showEnqueuedSnackbar(context);
              Navigator.pop(context);
            },
            leading: Icon(Icons.download_rounded),
            title: Text("Download All"),
          ),
        ],
      ),
    );
  }
}
