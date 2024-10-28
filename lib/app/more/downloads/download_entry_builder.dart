import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/extensions.dart';

class DownloadEntryBuilder extends StatelessWidget {
  const DownloadEntryBuilder({
    super.key,
    required this.entry,
    required this.index,
  });

  final TaskRecord entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        child: Text("${index + 1}"),
      ),
      title: Text(entry.task.displayName),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.status.name.normalizeCamelCase().toCapitalCase()),
              Text(" \u2022 "),
              Text(getFileSizeString(bytes: entry.expectedFileSize))
            ],
          ),
          LinearProgressIndicator(value: entry.progress)
        ],
      ),
      trailing: IconButton(
        onPressed: () => cancel(entry),
        icon: Icon(Icons.clear_rounded),
      ),
    );
  }

  Future<void> cancel(TaskRecord task) async {
    Iterable<TaskRecord> records = await FileDownloader().database.allRecords();
    records = records.where((element) => element.status != TaskStatus.complete);

    FileDownloader().cancelTasksWithIds(
      records.map((e) => e.taskId).toList(),
    );
  }

  String getFileSizeString({required int bytes, int decimals = 0}) {
    if (bytes.isNaN || bytes.isInfinite || bytes.isNegative) return "Unknown";
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }
}
