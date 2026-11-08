import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/video_actions.dart';
import '../../../core/widgets/video_list_tile.dart';
import '../../player/domain/player_controller.dart';
import '../../player/presentation/open_video.dart';
import '../data/playlist_repository.dart';
import 'playlist_name_dialog.dart';
import 'playlists_providers.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final int playlistId;

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  /// Cópia local para reordenação imediata (sem esperar o banco).
  List<VideoItem>? _items;

  PlaylistRepository get _repo => ref.read(playlistRepositoryProvider);

  Future<void> _rename(String current) async {
    final name = await PlaylistNameDialog.show(context, initial: current);
    if (name != null) await _repo.rename(widget.playlistId, name);
  }

  Future<void> _delete(String name) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.actionDelete),
        content: Text(l.deletePlaylistConfirm(name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionDelete)),
        ],
      ),
    );
    if (ok == true) {
      await _repo.delete(widget.playlistId);
      if (mounted) context.pop();
    }
  }

  void _play(List<VideoItem> items, {bool shuffle = false}) {
    if (items.isEmpty) return;
    ref.read(playerControllerProvider.notifier).playAll(items, shuffle: shuffle);
    openWatchScreen(context);
  }

  void _reorder(int oldIndex, int newIndex) {
    final items = List.of(_items!);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    setState(() => _items = items);
    _repo.reorder(widget.playlistId, items.map((v) => v.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final playlist = ref.watch(playlistByIdProvider(widget.playlistId)).value;
    ref.listen(playlistItemsProvider(widget.playlistId), (_, next) {
      if (next.hasValue) setState(() => _items = next.value);
    });
    final async = ref.watch(playlistItemsProvider(widget.playlistId));
    final items = _items ?? async.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist?.name ?? ''),
        actions: [
          if (playlist != null)
            PopupMenuButton<String>(
              tooltip: l.actionMenu,
              onSelected: (v) => v == 'rename'
                  ? _rename(playlist.name)
                  : _delete(playlist.name),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'rename', child: Text(l.actionRename)),
                PopupMenuItem(value: 'delete', child: Text(l.actionDelete)),
              ],
            ),
        ],
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: items.isEmpty ? null : () => _play(items),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l.playAll),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: items.isEmpty
                              ? null
                              : () => _play(items, shuffle: true),
                          icon: const Icon(Icons.shuffle),
                          label: Text(l.shuffle),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(l.playlistEmpty,
                                textAlign: TextAlign.center),
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          buildDefaultDragHandles: false,
                          itemCount: items.length,
                          onReorderItem: _reorder,
                          itemBuilder: (context, i) {
                            final item = items[i];
                            return VideoListTile(
                              key: ValueKey(item.id),
                              item: item,
                              thumbWidth: 140,
                              leading: ReorderableDragStartListener(
                                index: i,
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 8, 20),
                                  child: Icon(Icons.drag_handle),
                                ),
                              ),
                              extraActions: [
                                ExtraVideoAction(
                                  icon: Icons.playlist_remove,
                                  label: l.removeFromPlaylist,
                                  onSelected: () => _repo.removeVideo(
                                      widget.playlistId, item.id),
                                ),
                              ],
                              onTap: () =>
                                  openVideo(context, ref, item, queue: items),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
