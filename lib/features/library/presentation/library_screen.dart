import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/local_tube_app_bar.dart';
import '../../../core/widgets/video_actions.dart';
import '../../../core/widgets/video_list_tile.dart';
import '../../player/data/playback_repository.dart';
import '../../player/presentation/open_video.dart';
import '../domain/history_groups.dart';
import 'library_providers.dart';

/// Biblioteca: Histórico, Favoritos e Assistir mais tarde.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: LocalTubeAppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.history), text: l.historyTab),
              Tab(icon: const Icon(Icons.favorite_border), text: l.favoritesTab),
              Tab(icon: const Icon(Icons.watch_later_outlined), text: l.watchLaterTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_HistoryTab(), _FavoritesTab(), _WatchLaterTab()],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.clearHistory),
        content: Text(l.clearHistoryConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionClear)),
        ],
      ),
    );
    if (ok == true) await ref.read(playbackRepositoryProvider).clearHistory();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final history = ref.watch(historyProvider);
    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        if (items.isEmpty) {
          return _Empty(icon: Icons.history, text: l.historyEmpty);
        }
        final groups = groupHistory(items);
        final labels = {
          HistoryGroup.today: l.today,
          HistoryGroup.yesterday: l.yesterday,
          HistoryGroup.thisWeek: l.thisWeek,
          HistoryGroup.older: l.older,
        };
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextButton.icon(
                    onPressed: () => _clear(context, ref),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(l.clearHistory),
                  ),
                ),
              ),
            ),
            for (final entry in groups.entries) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(labels[entry.key]!, style: context.text.titleMedium),
                ),
              ),
              SliverList.builder(
                itemCount: entry.value.length,
                itemBuilder: (context, i) {
                  final item = entry.value[i];
                  return VideoListTile(
                    key: ValueKey(item.id),
                    item: item,
                    extraActions: [
                      ExtraVideoAction(
                        icon: Icons.history_toggle_off,
                        label: l.menuRemoveFromHistory,
                        onSelected: () => ref
                            .read(playbackRepositoryProvider)
                            .removeFromHistory(item.id),
                      ),
                    ],
                    onTap: () => openVideo(context, ref, item),
                  );
                },
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _SimpleList(
        async: ref.watch(favoritesProvider),
        emptyIcon: Icons.favorite_border,
        emptyText: context.l10n.favoritesEmpty,
      );
}

class _WatchLaterTab extends ConsumerWidget {
  const _WatchLaterTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _SimpleList(
        async: ref.watch(watchLaterProvider),
        emptyIcon: Icons.watch_later_outlined,
        emptyText: context.l10n.watchLaterEmpty,
      );
}

class _SimpleList extends ConsumerWidget {
  const _SimpleList({
    required this.async,
    required this.emptyIcon,
    required this.emptyText,
  });

  final AsyncValue<List<VideoItem>> async;
  final IconData emptyIcon;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? _Empty(icon: emptyIcon, text: emptyText)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) => VideoListTile(
                key: ValueKey(items[i].id),
                item: items[i],
                onTap: () => openVideo(context, ref, items[i], queue: items),
              ),
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: context.colors.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
