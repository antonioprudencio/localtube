import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_video_grid.dart';
import '../../../core/widgets/video_card.dart';
import '../../player/domain/player_controller.dart';
import '../../player/presentation/open_video.dart';
import '../domain/library_indexer.dart';
import 'folders_providers.dart';

/// Pasta exibida como "página de canal": banner, avatar, nome e grade.
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({super.key, required this.folderId});

  final int folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final folder = ref.watch(folderByIdProvider(folderId)).value;
    final videos = ref.watch(folderVideosProvider(folderId));
    final list = videos.value ?? const [];
    final totalBytes = list.fold<int>(0, (s, v) => s + v.video.sizeBytes);
    final available = folder != null && Directory(folder.path).existsSync();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            title: Text(folder?.name ?? ''),
            actions: [
              if (folder != null)
                IconButton(
                  tooltip: l.actionRescan,
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref
                      .read(libraryIndexerProvider.notifier)
                      .rescanFolder(folder),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _Banner(name: folder?.name ?? ''),
            ),
          ),
          if (folder != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    FolderAvatar(name: folder.name, radius: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(folder.name,
                              style: context.text.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            '${l.videoCount(list.length)} • ${Fmt.fileSize(totalBytes)}',
                            style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant),
                          ),
                          Text(
                            folder.lastScanAt == null
                                ? l.neverScanned
                                : l.lastScan(Fmt.dateTime(folder.lastScanAt!)),
                            style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (list.isNotEmpty)
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playAll(list);
                          openWatchScreen(context);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l.playAll),
                      ),
                  ],
                ),
              ),
            ),
          if (folder != null && !available)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.usb_off),
                    title: Text(l.folderUnavailable),
                    subtitle: Text(folder.path),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: Divider(height: 24)),
          if (videos.isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l.noVideosInFolder)),
            )
          else
            SliverVideoGrid(
              videos: list,
              showFolder: false,
              onTap: (item) => openVideo(context, ref, item, queue: list),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final hue = (name.hashCode.abs() % 360).toDouble();
    final c1 = HSLColor.fromAHSL(1, hue, 0.45, 0.32).toColor();
    final c2 = HSLColor.fromAHSL(1, (hue + 40) % 360, 0.5, 0.18).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(Icons.video_library_outlined,
              size: 72, color: Colors.white.withValues(alpha: 0.15)),
        ),
      ),
    );
  }
}
