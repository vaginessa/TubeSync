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
      title: Row(
        children: [
          Expanded(
            child: Text(
              entry.task.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => cancel(entry),
            icon: Icon(Icons.clear_rounded),
          ),
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.status.name.normalizeCamelCase().toCapitalCase()),
              Spacer(),
              Text("${(entry.progress * 100).toInt()}%"),
              SizedBox(width: 8),
            ],
          ),
          SizedBox(height: 6),
          LinearProgressIndicator(value: entry.progress)
        ],
      ),
    );
  }

  Future<void> cancel(TaskRecord task) async {
    FileDownloader().cancelTaskWithId(task.taskId);
    FileDownloader().database.deleteRecordWithId(task.taskId);
  }
}
