import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/folders/domain/library_indexer.dart';
import '../../features/folders/presentation/add_folder.dart';
import '../../features/player/domain/player_controller.dart';
import '../../features/player/presentation/mini_player.dart';
import '../../features/player/presentation/open_external.dart';
import '../../features/player/presentation/open_video.dart';
import '../../features/player/presentation/player_providers.dart';
import '../platform/platform_info.dart';
import '../utils/context_ext.dart';
import '../widgets/local_tube_logo.dart';
import 'routes.dart';

/// Estrutura de navegação: barra inferior (celular) ou rail lateral
/// recolhível (Windows/tablets), mini-player e arrastar e soltar.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _railExtended = false;
  bool _dragging = false;

  void _goBranch(int index) => widget.shell.goBranch(
        index,
        initialLocation: index == widget.shell.currentIndex,
      );

  Future<void> _onDrop(DropDoneDetails details) async {
    setState(() => _dragging = false);
    var played = false;
    for (final file in details.files) {
      final path = file.path;
      if (FileSystemEntity.isDirectorySync(path)) {
        if (mounted) await addFolderPath(context, ref, path);
      } else if (!played) {
        final item = await openExternalFile(ref, path);
        if (item != null && mounted) {
          played = true;
          openWatchScreen(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = context.isWide;
    final hasVideo = ref.watch(playerControllerProvider.select((s) => s.hasVideo));
    final watchVisible = ref.watch(watchScreenVisibleProvider);
    final showMini = hasVideo && !watchVisible;

    final destinations = [
      (Icons.home_outlined, Icons.home, l.navHome),
      (Icons.folder_outlined, Icons.folder, l.navFolders),
      (Icons.playlist_play_outlined, Icons.playlist_play, l.navPlaylists),
      (Icons.video_library_outlined, Icons.video_library, l.navLibrary),
    ];

    Widget body = widget.shell;

    if (wide) {
      body = Row(
        children: [
          NavigationRail(
            extended: _railExtended,
            minExtendedWidth: 220,
            selectedIndex: widget.shell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: _railExtended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.actionMenu,
                    icon: const Icon(Icons.menu),
                    onPressed: () =>
                        setState(() => _railExtended = !_railExtended),
                  ),
                  if (_railExtended) ...[
                    const SizedBox(width: 8),
                    const LocalTubeLogo(height: 18),
                  ],
                ],
              ),
            ),
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.$1),
                  selectedIcon: Icon(d.$2),
                  label: Text(d.$3),
                ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: widget.shell),
                if (showMini)
                  const Positioned(
                    right: 16,
                    bottom: 16,
                    child: MiniPlayer(floating: true),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    Widget scaffold = Scaffold(
      body: body,
      bottomNavigationBar: wide
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMini) const MiniPlayer(floating: false),
                NavigationBar(
                  selectedIndex: widget.shell.currentIndex,
                  onDestinationSelected: _goBranch,
                  destinations: [
                    for (final d in destinations)
                      NavigationDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2),
                        label: d.$3,
                      ),
                  ],
                ),
              ],
            ),
    );

    // Atalhos globais: Ctrl+F busca, F5 reescanear.
    scaffold = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
            context.push(Routes.search),
        const SingleActivator(LogicalKeyboardKey.f5): () {
          ref.read(libraryIndexerProvider.notifier).rescanAll();
          context.showSnack(l.rescanStarted);
        },
      },
      child: Focus(autofocus: true, child: scaffold),
    );

    if (!PlatformInfo.isDesktop) return scaffold;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: _onDrop,
      child: Stack(
        children: [
          scaffold,
          if (_dragging)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: context.colors.surfaceContainer,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download_outlined,
                            size: 48, color: context.colors.primary),
                        const SizedBox(height: 12),
                        Text(l.dropHere, style: context.text.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
