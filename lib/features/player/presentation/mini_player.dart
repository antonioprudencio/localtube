import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../domain/player_controller.dart';
import 'open_video.dart';

/// Mini-player: mantém o vídeo tocando enquanto o usuário navega.
/// [floating] = cartão no canto inferior direito (Windows/telas largas);
/// caso contrário, barra acima da navegação inferior (celular).
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, required this.floating});

  final bool floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);
    final item = session.current;
    if (item == null) return const SizedBox.shrink();
    final ctrl = ref.read(playerControllerProvider.notifier);

    final video = Video(
      controller: ctrl.videoController,
      controls: NoVideoControls,
      wakelock: false,
      pauseUponEnteringBackgroundMode: false,
      fill: Colors.black,
    );

    void expand() => openWatchScreen(context);

    final playPause = StreamBuilder<bool>(
      stream: ctrl.player.stream.playing,
      initialData: ctrl.player.state.playing,
      builder: (_, snap) {
        final playing = snap.data ?? false;
        return IconButton(
          tooltip: playing ? context.l10n.pause : context.l10n.play,
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          onPressed: ctrl.togglePlay,
        );
      },
    );
    final close = IconButton(
      tooltip: context.l10n.actionClose,
      icon: const Icon(Icons.close),
      onPressed: ctrl.close,
    );

    if (floating) {
      return Material(
        elevation: 8,
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: context.l10n.miniPlayerExpand,
                child: GestureDetector(
                  onTap: expand,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AbsorbPointer(child: video),
                    ),
                  ),
                ),
              ),
              _ProgressLine(player: ctrl.player),
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: expand,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall),
                          Text(item.folderName,
                              maxLines: 1,
                              style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                  playPause,
                  if (session.hasNext)
                    IconButton(
                      tooltip: context.l10n.next,
                      icon: const Icon(Icons.skip_next),
                      onPressed: ctrl.next,
                    ),
                  close,
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: context.colors.surfaceContainer,
      child: InkWell(
        onTap: expand,
        child: Semantics(
          label: context.l10n.miniPlayerExpand,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProgressLine(player: ctrl.player),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AbsorbPointer(child: video),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall),
                          Text(item.folderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    playPause,
                    close,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (context, snap) {
        final dur = player.state.duration.inMilliseconds;
        final pos = snap.data?.inMilliseconds ?? 0;
        return LinearProgressIndicator(
          value: dur <= 0 ? 0 : (pos / dur).clamp(0.0, 1.0),
          minHeight: 2,
          color: AppTheme.accent,
          backgroundColor: Colors.transparent,
        );
      },
    );
  }
}
