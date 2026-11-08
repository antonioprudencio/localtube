import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/filter_chips_bar.dart';
import '../../../core/widgets/local_tube_app_bar.dart';
import '../../../core/widgets/local_tube_logo.dart';
import '../../../core/widgets/responsive_video_grid.dart';
import '../../../core/widgets/video_thumbnail.dart';
import '../../folders/domain/library_indexer.dart';
import '../../folders/presentation/add_folder.dart';
import '../../player/presentation/open_video.dart';
import '../domain/home_filter.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider);
    return Scaffold(
      appBar: const LocalTubeAppBar(),
      body: switch (folders) {
        AsyncData(value: final list) when list.isEmpty => const WelcomeView(),
        AsyncData() => const _HomeContent(),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final filter = ref.watch(homeFilterStateProvider);
    final videos = ref.watch(homeVideosProvider);
    final folders = ref.watch(foldersProvider).value ?? const [];
    final containers = ref.watch(containersProvider).value ?? const [];
    final continueList = ref.watch(continueWatchingProvider).value ?? const [];

    final chips = <FilterChipData<HomeFilter>>[
      FilterChipData(value: const AllFilter(), label: l.filterAll),
      FilterChipData(
          value: const ContinueWatchingFilter(), label: l.filterContinue),
      FilterChipData(value: const RecentFilter(), label: l.filterRecent),
      FilterChipData(value: const UnwatchedFilter(), label: l.filterUnwatched),
      for (final f in folders)
        FilterChipData(
          value: FolderFilter(f.id),
          label: f.name,
          icon: Icons.folder_outlined,
        ),
      for (final c in containers)
        FilterChipData(value: FormatFilter(c), label: c.toUpperCase()),
    ];

    Future<void> refresh() =>
        ref.read(libraryIndexerProvider.notifier).rescanAll();

    final scroll = CustomScrollView(
      key: const PageStorageKey('home'),
      slivers: [
        SliverToBoxAdapter(
          child: FilterChipsBar<HomeFilter>(
            chips: chips,
            selected: filter,
            onSelected: ref.read(homeFilterStateProvider.notifier).select,
          ),
        ),
        if (filter is AllFilter && continueList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l.sectionContinue, style: context.text.titleMedium),
            ),
          ),
          SliverToBoxAdapter(child: ContinueWatchingRow(items: continueList)),
          const SliverToBoxAdapter(child: Divider(height: 24)),
        ],
        switch (videos) {
          AsyncData(:final value) when value.isEmpty => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l.emptyFilter, textAlign: TextAlign.center),
                ),
              ),
            ),
          AsyncData(:final value) => SliverVideoGrid(
              videos: value,
              onTap: (item) => openVideo(context, ref, item,
                  queue: filter is FolderFilter ? value : null),
            ),
          AsyncError(:final error) =>
            SliverToBoxAdapter(child: Center(child: Text('$error'))),
          _ => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
        },
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );

    // Pull-to-refresh no Android; no Windows, F5 / menu "Reescanear".
    return Platform.isAndroid
        ? RefreshIndicator(onRefresh: refresh, child: scroll)
        : scroll;
  }
}

/// Lista horizontal "Continuar assistindo".
class ContinueWatchingRow extends ConsumerWidget {
  const ContinueWatchingRow({super.key, required this.items});

  final List<VideoItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const width = 260.0;
    return SizedBox(
      height: width * 9 / 16 + 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return SizedBox(
            width: width,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openVideo(context, ref, item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VideoThumbnail(item: item, cacheWidth: 520),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Primeira execução: nenhuma pasta adicionada.
class WelcomeView extends ConsumerWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LocalTubeLogo(height: 56, showText: false),
              const SizedBox(height: 24),
              Text(
                l.welcomeTitle,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                l.welcomeBody,
                textAlign: TextAlign.center,
                style: context.text.bodyLarge
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => addFolderFlow(context, ref),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(l.welcomeButton),
              ),
              if (!Platform.isAndroid) ...[
                const SizedBox(height: 16),
                Text(
                  l.dropHere,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
