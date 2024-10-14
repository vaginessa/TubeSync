import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StreamController<String> controller = StreamController<String>(
    onListen: () async {
      var yt = YoutubeExplode();
      final filePath = (await getExternalStorageDirectory())!.path.replaceFirst("data", "media");
      var file = File("$filePath/muse");
      file.createSync();

      var manifest = await yt.videos.streamsClient.getManifest(
        'csa_KH1EclY',
      );
      var stream =
          yt.videos.streamsClient.get(manifest.audioOnly.withHighestBitrate());

      // Open a file for writing.

      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
      if (!controller.isClosed) {
        controller.close();
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    List<String> states = [];
    return StreamBuilder(
      stream: controller.stream,
      builder: (context, snapshot) {
        print(snapshot.toString());
        states.add(snapshot.toString());
        return Text(states.join("\n\n"));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (!controller.isClosed) controller.close();
  }

  @override
  void initState() {
    super.initState();
  }
}
