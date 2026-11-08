import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../core/platform/platform_info.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/player_controller.dart';
import 'player_settings_sheet.dart';
import 'seek_bar.dart';

/// Sobreposição de controles do player. A visibilidade (auto-ocultar após
/// 3 s) é controlada por `PlayerView`.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({
    super.key,
    required this.onInteraction,
    this.onMinimize,
    this.compact = false,
  });

  /// Reinicia o timer de auto-ocultar.
  final VoidCallback onInteraction;

  /// Minimizar para o mini-player (seta para baixo).
  final VoidCallback? onMinimize;

  /// Player pequeno (retrato no celular): esconde alguns botões.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);
    final ctrl = ref.read(playerControllerProvider.notifier);
    final player = ctrl.player;
    final l = context.l10n;
    final desktop = PlatformInfo.isDesktop;
    final title = session.current?.title ?? '';

    void act(VoidCallback f) {
      f();
      onInteraction();
    }

    final topBar = Row(
      children: [
        if (onMinimize != null && !session.fullscreen)
          IconButton(
            tooltip: l.actionClose,
            icon: const Icon(Icons.keyboard_arrow_down, size: 28),
            onPressed: onMinimize,
          )
        else if (session.fullscreen)
          IconButton(
            tooltip: l.exitFullscreen,
            icon: const Icon(Icons.arrow_back),
            onPressed: ctrl.exitFullscreen,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              session.fullscreen || desktop ? title : '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (PlatformInfo.isAndroid) ...[
          if (session.fullscreen)
            IconButton(
              tooltip: l.lockControls,
              icon: const Icon(Icons.lock_outline),
              onPressed: () => ctrl.setLocked(true),
            ),
          IconButton(
            tooltip: l.pictureInPicture,
            icon: const Icon(Icons.picture_in_picture_alt_outlined),
            onPressed: ctrl.enterPip,
          ),
        ],
        IconButton(
          tooltip: l.playerSettings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => PlayerSettingsSheet.show(context),
        ),
      ],
    );

    final center = desktop
        ? const SizedBox.shrink()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundButton(
                icon: Icons.skip_previous,
                tooltip: l.previous,
                size: compact ? 28 : 36,
                onPressed: () => act(ctrl.previous),
              ),
              SizedBox(width: compact ? 24 : 48),
              _PlayPauseButton(
                player: player,
                size: compact ? 44 : 56,
                onPressed: () => act(ctrl.togglePlay),
              ),
              SizedBox(width: compact ? 24 : 48),
              _RoundButton(
                icon: Icons.skip_next,
                tooltip: l.next,
                size: compact ? 28 : 36,
                onPressed: session.hasNext ? () => act(ctrl.next) : null,
              ),
            ],
          );

    final bottomBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SeekBar(
            player: player,
            onSeek: ctrl.seek,
            onInteraction: onInteraction,
          ),
        ),
        Row(
          children: [
            if (desktop) ...[
              _PlayPauseButton(
                player: player,
                size: 28,
                flat: true,
                onPressed: () => act(ctrl.togglePlay),
              ),
              IconButton(
                tooltip: '${l.next} (Shift+N)',
                icon: const Icon(Icons.skip_next),
                onPressed: session.hasNext ? () => act(ctrl.next) : null,
              ),
              _VolumeControl(player: player, onChanged: onInteraction),
            ] else
              const SizedBox(width: 8),
            _TimeLabel(player: player),
            const Spacer(),
            IconButton(
              tooltip: '${l.subtitles} (C)',
              icon: StreamBuilder<Track>(
                stream: player.stream.track,
                initialData: player.state.track,
                builder: (_, snap) => Icon(
                  snap.data?.subtitle.id == 'no'
                      ? Icons.closed_caption_disabled_outlined
                      : Icons.closed_caption,
                ),
              ),
              onPressed: () => act(ctrl.toggleSubtitles),
            ),
            if (desktop && !session.fullscreen && context.isWide)
              IconButton(
                tooltip: l.theaterMode,
                icon: Icon(session.theater
                    ? Icons.crop_7_5
                    : Icons.crop_landscape_outlined),
                onPressed: () => act(ctrl.toggleTheater),
              ),
            IconButton(
              tooltip: session.fullscreen
                  ? '${l.exitFullscreen} (F)'
                  : '${l.fullscreen} (F)',
              icon: Icon(session.fullscreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen),
              onPressed: () => act(ctrl.toggleFullscreen),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ],
    );

    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x99000000),
                Color(0x22000000),
                Color(0x22000000),
                Color(0xAA000000),
              ],
              stops: [0, 0.25, 0.65, 1],
            ),
          ),
          child: SafeArea(
            top: session.fullscreen,
            bottom: session.fullscreen,
            child: Column(
              children: [
                topBar,
                Expanded(child: Center(child: center)),
                bottomBar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 36,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        iconSize: size,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black38,
          disabledForegroundColor: Colors.white38,
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      );
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.player,
    required this.onPressed,
    this.size = 56,
    this.flat = false,
  });

  final Player player;
  final VoidCallback onPressed;
  final double size;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return StreamBuilder<bool>(
      stream: player.stream.playing,
      initialData: player.state.playing,
      builder: (context, snap) {
        final playing = snap.data ?? false;
        return IconButton(
          tooltip: '${playing ? l.pause : l.play} (K)',
          iconSize: size,
          style: flat
              ? null
              : IconButton.styleFrom(backgroundColor: Colors.black38),
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          onPressed: onPressed,
        );
      },
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (context, snap) {
        final pos = snap.data ?? Duration.zero;
        final dur = player.state.duration;
        return Text(
          '${Fmt.duration(pos)} / ${Fmt.duration(dur)}',
          style: const TextStyle(
            fontSize: 13,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

class _VolumeControl extends ConsumerStatefulWidget {
  const _VolumeControl({required this.player, required this.onChanged});

  final Player player;
  final VoidCallback onChanged;

  @override
  ConsumerState<_VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends ConsumerState<_VolumeControl> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ctrl = ref.read(playerControllerProvider.notifier);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: StreamBuilder<double>(
        stream: widget.player.stream.volume,
        initialData: widget.player.state.volume,
        builder: (context, snap) {
          final v = snap.data ?? 100;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '${v == 0 ? l.unmute : l.mute} (M)',
                icon: Icon(v == 0
                    ? Icons.volume_off
                    : v < 50
                        ? Icons.volume_down
                        : Icons.volume_up),
                onPressed: ctrl.toggleMute,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _hover ? 96 : 0,
                child: _hover
                    ? Slider(
                        value: v.clamp(0, 100),
                        max: 100,
                        label: l.volumeLabel(v.round()),
                        onChanged: (x) {
                          ctrl.setVolume(x);
                          widget.onChanged();
                        },
                      )
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
