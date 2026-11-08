import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/local_tube_app_bar.dart';
import '../../../core/widgets/video_card.dart';
import '../data/folder_repository.dart';
import '../domain/library_indexer.dart';
import 'add_folder.dart';
import 'folders_providers.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final summaries = ref.watch(folderSummariesProvider);

    return Scaffold(
      appBar: const LocalTubeAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-folder',
        onPressed: () => addFolderFlow(context, ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l.actionAddFolder),
      ),
      body: switch (summaries) {
        AsyncData(:final value) when value.isEmpty => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 56, color: context.colors.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(l.foldersEmpty),
              ],
            ),
          ),
        AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.only(bottom: 96, top: 8),
            itemCount: value.length,
            itemBuilder: (context, i) => _FolderTile(summary: value[i]),
          ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({required this.summary});

  final FolderSummary summary;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.removeFolder),
        content: Text(l.removeFolderConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionRemove)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(libraryIndexerProvider.notifier).removeFolder(summary.folder.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final f = summary.folder;
    final available = Directory(f.path).existsSync();
    final subtitle = [
      l.videoCount(summary.videoCount),
      Fmt.fileSize(summary.totalBytes),
      if (!available) l.folderUnavailable,
    ].join(' • ');

    return ListTile(
      minVerticalPadding: 12,
      leading: FolderAvatar(name: f.name, radius: 22),
      title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Text(
            f.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
      onTap: () => context.push(Routes.folder(f.id)),
      trailing: PopupMenuButton<String>(
        tooltip: l.actionMenu,
        onSelected: (v) {
          if (v == 'rescan') {
            ref.read(libraryIndexerProvider.notifier).rescanFolder(f);
          } else if (v == 'remove') {
            _remove(context, ref);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'rescan', child: Text(l.actionRescan)),
          PopupMenuItem(value: 'remove', child: Text(l.removeFolder)),
        ],
      ),
    );
  }
}
