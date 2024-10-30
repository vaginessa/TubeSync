import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/app/more/downloads/download_entry_builder.dart';
import 'package:tube_sync/main.dart';
import 'package:tube_sync/services/media_service.dart';

class ActiveDownloadsScreen extends StatefulWidget {
  const ActiveDownloadsScreen({super.key});

  @override
  State<ActiveDownloadsScreen> createState() => _ActiveDownloadsScreenState();

  static void notificationTapHandler(
    Task task,
    NotificationType notificationType,
  ) {
    rootNavigator.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ActiveDownloadsScreen()),
      (route) => route.isFirst,
    );
  }

  static void downloadStatusListener(TaskStatusUpdate update) {
    switch (update.status) {
      case TaskStatus.complete:
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        FileDownloader().database.deleteRecordWithId(update.task.taskId);
        break;

      default:
        break;
    }
  }

  static void showEnqueuedSnackbar(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text("Downloading....."),
        action: SnackBarAction(
          label: "View",
          onPressed: () => rootNavigator.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => ActiveDownloadsScreen()),
            (route) => route.isFirst,
          ),
        ),
      ),
    );
  }
}

class _ActiveDownloadsScreenState extends State<ActiveDownloadsScreen> {
  @override
  void initState() {
    super.initState();
    FileDownloader().registerCallbacks(
      taskProgressCallback: taskProgressCallback,
      taskStatusCallback: taskStatusCallback,
    );
  }

  @override
  void dispose() {
    super.dispose();
    FileDownloader().unregisterCallbacks(callback: taskProgressCallback);
    FileDownloader().unregisterCallbacks(callback: taskStatusCallback);
  }

  Future<void> cancelAll() async {
    FileDownloader().taskQueues.forEach(FileDownloader().removeTaskQueue);
    MediaService().abortQueueing();
    Iterable<TaskRecord> records = await FileDownloader().database.allRecords();

    await FileDownloader().cancelTasksWithIds(
      records.map((e) => e.taskId).toList(),
    );
    await FileDownloader().database.deleteAllRecords();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Active Downloads")),
      floatingActionButton: FutureBuilder(
        future: FileDownloader().database.allRecords(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) return const SizedBox();
          if (snapshot.requireData.isEmpty) return const SizedBox();
          return FloatingActionButton.extended(
            icon: Icon(Icons.clear_all_rounded),
            label: Text("Cancel All"),
            onPressed: cancelAll,
          );
        },
      ),
      body: FutureBuilder<List<TaskRecord>>(
        future: FileDownloader().database.allRecords(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.requireData.isEmpty) {
            return Center(child: Text("No Active Downloads!"));
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2),
            itemBuilder: (context, index) {
              final entry = snapshot.requireData[index];
              return DownloadEntryBuilder(
                key: ValueKey(entry.hashCode),
                index: index,
                entry: entry,
              );
            },
          );
        },
      ),
    );
  }

  void taskProgressCallback(TaskProgressUpdate _) => setState(() {});

  void taskStatusCallback(TaskStatusUpdate update) {
    switch (update.status) {
      case TaskStatus.complete:
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        FileDownloader()
            .database
            .deleteRecordWithId(update.task.taskId)
            .whenComplete(() => setState(() {}));
        break;

      default:
        setState(() {});
        break;
    }
  }
}
