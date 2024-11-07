import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/library/empty_library_view.dart';
import 'package:tube_sync/app/library/import_playlist_dialog.dart';
import 'package:tube_sync/app/library/library_entry_builder.dart';
import 'package:tube_sync/app/playlist/playlist_tab.dart';
import 'package:tube_sync/provider/library_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';
import 'package:tube_sync/services/media_service.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          if (library.entries.isEmpty) return const EmptyLibraryView();
          return RefreshIndicator(
            onRefresh: library.refresh,
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 8,
                bottom: kBottomNavigationBarHeight * 2,
              ),
              itemCount: library.entries.length,
              itemBuilder: (context, index) {
                final playlist = library.entries[index];
                return LibraryEntryBuilder(
                  playlist,
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.ease)),
                          ),
                          child: child,
                        );
                      },
                      pageBuilder: (context, _, __) {
                        return ChangeNotifierProvider<PlaylistProvider>(
                          child: PlaylistTab(),
                          create: (_) => PlaylistProvider(
                            context.read<Isar>(),
                            playlist,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: MediaService().isPlayerBinded,
        builder: (_, playerBinded, fab) {
          if (!playerBinded) return fab!;
          return Padding(
            padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight * 1.25),
            child: fab,
          );
        },
        child: FloatingActionButton.extended(
          onPressed: () => showDialog(
            context: context,
            useRootNavigator: true,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.watch<LibraryProvider>(),
              child: const ImportPlaylistDialog(),
            ),
          ),
          label: const Text("Import"),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
