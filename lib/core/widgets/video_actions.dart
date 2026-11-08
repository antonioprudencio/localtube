import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/data/video_repository.dart';
import '../../features/library/presentation/video_info_sheet.dart';
import '../../features/player/data/playback_repository.dart';
import '../../features/playlists/presentation/add_to_playlist_sheet.dart';
import '../models/video_item.dart';
import '../platform/platform_info.dart';
import '../platform/windows_shell.dart';
import '../utils/context_ext.dart';

/// Ação extra específica de uma tela (ex.: "Remover da playlist").
class ExtraVideoAction {
  const ExtraVideoAction({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
}

enum _Action {
  addToPlaylist,
  favorite,
  watchLater,
  watched,
  info,
  reveal,
  remove,
}

/// Menu "⋮" de um vídeo. No desktop/telas largas abre um menu suspenso
/// (também usado no clique direito); no celular, uma folha inferior.
abstract final class VideoActions {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    VideoItem item, {
    Offset? globalPosition,
    List<ExtraVideoAction> extra = const [],
  }) async {
    final l = context.l10n;
    final v = item.video;
    final entries = <(_Action?, IconData, String, ExtraVideoAction?)>[
      (_Action.addToPlaylist, Icons.playlist_add, l.menuAddToPlaylist, null),
      (
        _Action.favorite,
        v.isFavorite ? Icons.favorite : Icons.favorite_border,
        v.isFavorite ? l.menuUnfavorite : l.menuFavorite,
        null,
      ),
      (
        _Action.watchLater,
        v.watchLater ? Icons.watch_later : Icons.watch_later_outlined,
        v.watchLater ? l.menuRemoveWatchLater : l.menuWatchLater,
        null,
      ),
      (
        _Action.watched,
        item.isCompleted ? Icons.remove_done : Icons.done_all,
        item.isCompleted ? l.menuMarkUnwatched : l.menuMarkWatched,
        null,
      ),
      (_Action.info, Icons.info_outline, l.menuInfo, null),
      if (PlatformInfo.isWindows)
        (_Action.reveal, Icons.folder_open_outlined, l.menuOpenInExplorer, null),
      for (final e in extra) (null, e.icon, e.label, e),
      (_Action.remove, Icons.delete_outline, l.menuRemoveFromLibrary, null),
    ];

    final int? selected;
    if (globalPosition != null || context.isWide) {
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      final box = context.findRenderObject() as RenderBox?;
      final pos = globalPosition ??
          (box == null
              ? overlay.size.center(Offset.zero)
              : box.localToGlobal(box.size.topRight(Offset.zero)));
      selected = await showMenu<int>(
        context: context,
        position: RelativeRect.fromRect(
          pos & const Size(1, 1),
          Offset.zero & overlay.size,
        ),
        items: [
          for (var i = 0; i < entries.length; i++)
            PopupMenuItem(
              value: i,
              child: Row(
                children: [
                  Icon(entries[i].$2, size: 20),
                  const SizedBox(width: 12),
                  Text(entries[i].$3),
                ],
              ),
            ),
        ],
      );
    } else {
      selected = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        builder: (ctx) => ListView(
          shrinkWrap: true,
          children: [
            for (var i = 0; i < entries.length; i++)
              ListTile(
                leading: Icon(entries[i].$2),
                title: Text(entries[i].$3),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      );
    }

    if (selected == null || !context.mounted) return;
    final entry = entries[selected];
    if (entry.$4 != null) {
      entry.$4!.onSelected();
      return;
    }
    await _run(context, ref, item, entry.$1!);
  }

  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    VideoItem item,
    _Action action,
  ) async {
    final videos = ref.read(videoRepositoryProvider);
    final v = item.video;
    switch (action) {
      case _Action.addToPlaylist:
        await AddToPlaylistSheet.show(context, item);
      case _Action.favorite:
        await videos.setFavorite(v.id, !v.isFavorite);
      case _Action.watchLater:
        await videos.setWatchLater(v.id, !v.watchLater);
      case _Action.watched:
        await ref
            .read(playbackRepositoryProvider)
            .setCompleted(v.id, !item.isCompleted);
      case _Action.info:
        await VideoInfoSheet.show(context, item);
      case _Action.reveal:
        await WindowsShell.revealInExplorer(v.path);
      case _Action.remove:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(ctx.l10n.menuRemoveFromLibrary),
            content: Text(ctx.l10n.removeFromLibraryConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctx.l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ctx.l10n.actionRemove),
              ),
            ],
          ),
        );
        if (ok == true) await videos.removeFromLibrary(v.id);
    }
  }
}
