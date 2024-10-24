import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:tube_sync/main.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Active Downloads")),
      body: FutureBuilder<List<TaskRecord>>(
        future: FileDownloader().database.allRecords(),
        builder: (context, snapshot) => ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            return Text(snapshot.data![index].toString());
          },
        ),
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
        FileDownloader().database.deleteRecordWithId(update.task.taskId).then(
              (_) => setState(() {}),
            );
        break;

      default:
        setState(() {});
        break;
    }
  }
}
