import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/folders/domain/library_indexer.dart';
import '../../features/folders/presentation/add_folder.dart';
import '../router/routes.dart';
import '../utils/context_ext.dart';
import 'local_tube_logo.dart';

/// AppBar padrão das abas principais: logo, busca, adicionar pasta e menu.
class LocalTubeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const LocalTubeAppBar({super.key, this.title, this.bottom});

  /// Título opcional (substitui o logo em telas internas).
  final String? title;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 3 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indexer = ref.watch(libraryIndexerProvider);
    final l = context.l10n;
    final showLogo = title == null;

    return AppBar(
      automaticallyImplyLeading: !showLogo,
      title: showLogo ? const LocalTubeLogo(height: 22) : Text(title!),
      actions: [
        IconButton(
          tooltip: '${l.actionSearch} (Ctrl+F)',
          icon: const Icon(Icons.search),
          onPressed: () => context.push(Routes.search),
        ),
        IconButton(
          tooltip: l.actionAddFolder,
          icon: const Icon(Icons.create_new_folder_outlined),
          onPressed: () => addFolderFlow(context, ref),
        ),
        PopupMenuButton<String>(
          tooltip: l.actionMenu,
          icon: const Icon(Icons.more_vert),
          onSelected: (v) {
            switch (v) {
              case 'settings':
                context.push(Routes.settings);
              case 'rescan':
                ref.read(libraryIndexerProvider.notifier).rescanAll();
                context.showSnack(l.rescanStarted);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'rescan',
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l.actionRescan),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l.actionSettings),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(3 + (bottom?.preferredSize.height ?? 0)),
        child: Column(
          children: [
            ?bottom,
            SizedBox(
              height: 3,
              child: indexer.busy
                  ? Tooltip(
                      message: indexer.scanning
                          ? l.scanning
                          : l.processing(indexer.pendingProbe),
                      child: const LinearProgressIndicator(minHeight: 3),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
