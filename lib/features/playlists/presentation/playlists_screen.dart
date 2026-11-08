import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/local_tube_app_bar.dart';
import '../data/playlist_repository.dart';
import 'playlist_name_dialog.dart';
import 'playlists_providers.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await PlaylistNameDialog.show(context);
    if (name != null) await ref.read(playlistRepositoryProvider).create(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final playlists = ref.watch(playlistSummariesProvider);

    return Scaffold(
      appBar: const LocalTubeAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-playlist',
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.newPlaylist),
      ),
      body: switch (playlists) {
        AsyncData(:final value) when value.isEmpty => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_play,
                      size: 56, color: context.colors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(l.playlistsEmpty, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
            itemCount: value.length,
            itemBuilder: (context, i) => _PlaylistTile(summary: value[i]),
          ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  const _PlaylistTile({required this.summary});

  final PlaylistSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = summary.playlist;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(Routes.playlist(p.id)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: PlaylistCover(
                thumb: summary.coverThumb,
                count: summary.itemCount,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.videoCount(summary.itemCount),
                    style: context.text.bodySmall
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Capa de playlist: miniatura do primeiro vídeo + faixa com a contagem.
class PlaylistCover extends StatelessWidget {
  const PlaylistCover({super.key, required this.thumb, required this.count});

  final String? thumb;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.thumbRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.surfaceContainerHigh),
            if (thumb != null)
              Image.file(File(thumb!),
                  fit: BoxFit.cover,
                  cacheWidth: 320,
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 64,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$count',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    const Icon(Icons.playlist_play, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
