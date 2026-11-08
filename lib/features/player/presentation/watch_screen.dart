import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/video_item.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/video_card.dart';
import '../../../core/widgets/video_list_tile.dart';
import '../../library/data/video_repository.dart';
import '../../library/presentation/video_info_sheet.dart';
import '../../playlists/presentation/add_to_playlist_sheet.dart';
import '../domain/player_controller.dart';
import '../domain/player_session.dart';
import 'player_providers.dart';
import 'widgets/player_shortcuts.dart';
import 'widgets/player_view.dart';

/// Tela de reprodução.
class WatchScreen extends ConsumerStatefulWidget {
  const WatchScreen({super.key});

  @override
  ConsumerState<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends ConsumerState<WatchScreen> {
  bool _fullscreenByRotation = false;
  DateTime _lastManualExit = DateTime(0);
  late final WatchScreenVisible _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = ref.read(watchScreenVisibleProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _visibility.set(true));
  }

  @override
  void dispose() {
    final ctrl = ref.read(playerControllerProvider.notifier);
    // Ao sair da tela, garante que a janela/sistema saiam da tela cheia.
    unawaited(ctrl.exitFullscreen());
    unawaited(ctrl.saveNow());
    Future.microtask(() => _visibility.set(false));
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!PlatformInfo.isAndroid) return;
    // Celular: girar para paisagem entra em tela cheia; voltar para retrato sai.
    final orientation = MediaQuery.orientationOf(context);
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    if (shortest >= 600) return; // tablets usam o layout de duas colunas
    final ctrl = ref.read(playerControllerProvider.notifier);
    final fullscreen = ref.read(playerControllerProvider).fullscreen;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (orientation == Orientation.landscape && !fullscreen) {
        if (DateTime.now().difference(_lastManualExit).inMilliseconds < 1500) {
          return;
        }
        _fullscreenByRotation = true;
        ctrl.enterFullscreen(forceLandscape: false);
      } else if (orientation == Orientation.portrait &&
          fullscreen &&
          _fullscreenByRotation) {
        _fullscreenByRotation = false;
        ctrl.exitFullscreen();
      }
    });
  }

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    ref.listen(playerControllerProvider.select((s) => s.fullscreen), (prev, now) {
      if (prev == true && !now && !_fullscreenByRotation) {
        _lastManualExit = DateTime.now();
      }
      if (!now) _fullscreenByRotation = false;
    });

    final current = session.current;

    Widget body;
    if (current == null) {
      body = Center(child: Text(context.l10n.nothingPlaying));
    } else if (session.fullscreen) {
      body = PlayerView(onMinimize: _minimize);
    } else {
      body = LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 900;
        return wide
            ? _WideLayout(session: session, onMinimize: _minimize)
            : _NarrowLayout(session: session, onMinimize: _minimize);
      });
    }

    return PopScope(
      canPop: !session.fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && session.fullscreen) {
          ref.read(playerControllerProvider.notifier).exitFullscreen();
        }
      },
      child: PlayerShortcuts(
        child: Scaffold(
          backgroundColor: session.fullscreen ? Colors.black : null,
          body: body,
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.session, required this.onMinimize});

  final PlayerSession session;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColoredBox(
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: PlayerView(onMinimize: onMinimize, compact: true),
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _VideoDetails(session: session)),
              ..._upNextSlivers(context, session),
            ],
          ),
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.session, required this.onMinimize});

  final PlayerSession session;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    if (session.theater) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: height * 0.72,
              child: PlayerView(onMinimize: onMinimize),
            ),
          ),
          SliverCrossAxisGroup(
            slivers: [
              SliverConstrainedCrossAxis(
                maxExtent: 900,
                sliver: SliverToBoxAdapter(child: _VideoDetails(session: session)),
              ),
              SliverMainAxisGroup(slivers: _upNextSlivers(context, session)),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PlayerView(onMinimize: onMinimize),
                ),
              ),
              _VideoDetails(session: session, padding: EdgeInsets.zero),
            ],
          ),
        ),
        SizedBox(
          width: 420,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ..._upNextSlivers(context, session),
            ],
          ),
        ),
      ],
    );
  }
}

/// Título, metadados, botões em pílula e detalhes técnicos.
class _VideoDetails extends ConsumerWidget {
  const _VideoDetails({
    required this.session,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final PlayerSession session;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = session.current!;
    final live = ref.watch(videoByIdProvider(snapshot.id)).value ?? snapshot;
    final l = context.l10n;
    final ctrl = ref.read(playerControllerProvider.notifier);
    final v = live.video;

    final repeatIcon = switch (session.repeat) {
      LoopMode.off => Icons.repeat,
      LoopMode.one => Icons.repeat_one_on,
      LoopMode.all => Icons.repeat_on,
    };
    final repeatLabel = switch (session.repeat) {
      LoopMode.off => l.watchRepeat,
      LoopMode.one => l.repeatOne,
      LoopMode.all => l.repeatAll,
    };

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            live.title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: context.isWide ? 20 : 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FolderAvatar(name: live.folderName),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  videoMetaLine(live),
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Pill(
                  icon: v.isFavorite ? Icons.favorite : Icons.favorite_border,
                  label: v.isFavorite ? l.watchFavorited : l.watchFavorite,
                  onPressed: () => ref
                      .read(videoRepositoryProvider)
                      .setFavorite(v.id, !v.isFavorite),
                ),
                _Pill(
                  icon: Icons.playlist_add,
                  label: l.watchSave,
                  onPressed: () => AddToPlaylistSheet.show(context, live),
                ),
                _Pill(
                  icon: repeatIcon,
                  label: repeatLabel,
                  onPressed: ctrl.cycleRepeat,
                ),
                _Pill(
                  icon: Icons.info_outline,
                  label: l.watchInfo,
                  onPressed: () => VideoInfoSheet.show(context, live),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: Text(l.watchDetails, style: context.text.titleSmall),
              shape: const Border(),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [VideoTechDetails(item: live)],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 40),
        ),
      ),
    );
  }
}

/// Cabeçalho "A seguir" + lista da fila.
List<Widget> _upNextSlivers(BuildContext context, PlayerSession session) {
  final upNext = session.upNext;
  return [
    SliverToBoxAdapter(child: _UpNextHeader(session: session)),
    SliverList.builder(
      itemCount: upNext.length,
      itemBuilder: (context, i) => _UpNextTile(
        item: upNext[i],
        queueIndex: session.index + 1 + i,
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 24)),
  ];
}

class _UpNextHeader extends ConsumerWidget {
  const _UpNextHeader({required this.session});

  final PlayerSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(child: Text(l.upNext, style: context.text.titleMedium)),
          Text(l.autoplay, style: context.text.bodySmall),
          Switch(
            value: session.autoplay,
            onChanged: ref.read(playerControllerProvider.notifier).setAutoplay,
          ),
        ],
      ),
    );
  }
}

class _UpNextTile extends ConsumerWidget {
  const _UpNextTile({required this.item, required this.queueIndex});

  final VideoItem item;
  final int queueIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(videoByIdProvider(item.id)).value ?? item;
    return VideoListTile(
      item: live,
      onTap: () =>
          ref.read(playerControllerProvider.notifier).playFromQueue(queueIndex),
    );
  }
}
