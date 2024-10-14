import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ImportPlaylistDialog extends StatefulWidget {
  const ImportPlaylistDialog({super.key});

  @override
  State<ImportPlaylistDialog> createState() => _ImportPlaylistDialogState();
}

class _ImportPlaylistDialogState extends State<ImportPlaylistDialog> {
  final ytClient = YoutubeExplode().playlists;
  final TextEditingController input = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> tryImportPlaylist() async {
    try {
      error = null;
      setState(() => loading = true);
      if (input.text.isEmpty) throw "Empty url";
      final playlist = await ytClient.get(input.text);
      if (mounted) Navigator.pop(context, playlist);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Playlist"),
      icon: const Icon(CupertinoIcons.link),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: input,
            autofocus: true,
            maxLines: 5,
            minLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Playlist URL",
              hintText: "https://youtu.be/playlist?list=...",
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (error != null)
            Card(
              margin: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(onPressed: tryImportPlaylist, child: const Text("Import"))
      ],
    );
  }
}
