import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/platform/android_system.dart';
import '../../../../core/platform/platform_info.dart';
import '../../../../core/utils/context_ext.dart';
import '../../domain/player_controller.dart';
import '../../domain/player_session.dart';
import 'player_controls.dart';

/// Vídeo com controles, gestos (toque) e interações de mouse.
class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({super.key, this.onMinimize, this.compact = false});

  /// Minimizar para o mini-player (arrastar para baixo / seta).
  final VoidCallback? onMinimize;
  final bool compact;

  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

enum _Side { left, right }

class _PlayerViewState extends ConsumerState<PlayerView> {
  static const _hideDelay = Duration(seconds: 3);
  static const _seekStep = Duration(seconds: 10);

  bool _controlsVisible = true;
  Timer? _hideTimer;
  StreamSubscription<bool>? _playingSub;

  // Feedback visual (volume, brilho, zoom, ±10 s).
  String? _feedbackText;
  IconData? _feedbackIcon;
  Timer? _feedbackTimer;
  _Side? _rippleSide;
  int _rippleCount = 0;
  Timer? _rippleTimer;

  // Gestos de arrastar.
  Offset? _doubleTapPosition;
  double _dragAccum = 0;
  _DragKind? _dragKind;
  double _brightness = 0.5;
  double _volumeAtStart = 100;
  double _scaleAtStart = 1;

  PlayerController get _ctrl => ref.read(playerControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _playingSub = _ctrl.player.stream.playing.listen((playing) {
      if (playing) {
        _scheduleHide();
      } else {
        _show(autoHide: false);
      }
    });
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _feedbackTimer?.cancel();
    _rippleTimer?.cancel();
    _playingSub?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (mounted && _ctrl.player.state.playing) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _show({bool autoHide = true}) {
    if (!mounted) return;
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    if (autoHide) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _show();
    }
  }

  void _showFeedback(IconData icon, String text) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackIcon = icon;
      _feedbackText = text;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _feedbackText = null);
    });
  }

  // ---------------------------------------------------------------------------
  // Toque
  // ---------------------------------------------------------------------------

  void _onDoubleTap(double width) {
    final pos = _doubleTapPosition;
    if (pos == null) return;
    final x = pos.dx;
    if (x < width / 3) {
      _seekWithRipple(_Side.left);
    } else if (x > width * 2 / 3) {
      _seekWithRipple(_Side.right);
    } else {
      _ctrl.togglePlay();
    }
  }

  void _seekWithRipple(_Side side) {
    _ctrl.seekRelative(side == _Side.left ? -_seekStep : _seekStep);
    _rippleTimer?.cancel();
    setState(() {
      _rippleCount = _rippleSide == side ? _rippleCount + 1 : 1;
      _rippleSide = side;
    });
    _rippleTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _rippleSide = null);
    });
  }

  Future<void> _onScaleStart(ScaleStartDetails d, Size size) async {
    _dragAccum = 0;
    _dragKind = null;
    _scaleAtStart = 1;
    if (d.pointerCount >= 2) {
      _dragKind = _DragKind.pinch;
      return;
    }
    final fullscreen = ref.read(playerControllerProvider).fullscreen;
    if (fullscreen) {
      _dragKind = d.localFocalPoint.dx < size.width / 2
          ? _DragKind.brightness
          : _DragKind.volume;
      _volumeAtStart = _ctrl.player.state.volume;
      if (_dragKind == _DragKind.brightness) {
        _brightness = await AndroidSystem.brightness();
      }
    } else if (widget.onMinimize != null) {
      _dragKind = _DragKind.minimize;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d, Size size) {
    if (d.pointerCount >= 2 || _dragKind == _DragKind.pinch) {
      _dragKind = _DragKind.pinch;
      _scaleAtStart = d.scale;
      return;
    }
    final dy = d.focalPointDelta.dy;
    switch (_dragKind) {
      case _DragKind.brightness:
        _brightness = (_brightness - dy / (size.height * 0.8)).clamp(0.0, 1.0);
        AndroidSystem.setBrightness(_brightness);
        _showFeedback(Icons.brightness_6,
            context.l10n.brightnessLabel((_brightness * 100).round()));
      case _DragKind.volume:
        _volumeAtStart =
            (_volumeAtStart - dy / (size.height * 0.8) * 100).clamp(0.0, 100.0);
        _ctrl.setVolume(_volumeAtStart);
        _showFeedback(
          _volumeAtStart == 0 ? Icons.volume_off : Icons.volume_up,
          context.l10n.volumeLabel(_volumeAtStart.round()),
        );
      case _DragKind.minimize:
        _dragAccum += dy;
      case _DragKind.pinch:
      case null:
        break;
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    switch (_dragKind) {
      case _DragKind.pinch:
        if (_scaleAtStart > 1.1) {
          _ctrl.setFit(VideoFit.fill);
          _showFeedback(Icons.zoom_out_map, context.l10n.aspectFill);
        } else if (_scaleAtStart < 0.9) {
          _ctrl.setFit(VideoFit.fit);
          _showFeedback(Icons.fit_screen, context.l10n.aspectFit);
        }
      case _DragKind.minimize:
        if (_dragAccum > 80 || d.velocity.pixelsPerSecond.dy > 900) {
          widget.onMinimize?.call();
        }
      default:
        break;
    }
    _dragKind = null;
  }

  // ---------------------------------------------------------------------------
  // Mouse
  // ---------------------------------------------------------------------------

  void _onPointerSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      final delta = e.scrollDelta.dy < 0 ? 5.0 : -5.0;
      _ctrl.changeVolume(delta);
      final v = (_ctrl.player.state.volume + delta).clamp(0, 100).round();
      _showFeedback(v == 0 ? Icons.volume_off : Icons.volume_up,
          context.l10n.volumeLabel(v));
      _show();
    }
  }

  // ---------------------------------------------------------------------------

  ({BoxFit fit, double? aspect}) _fitFor(VideoFit f) => switch (f) {
        VideoFit.fit => (fit: BoxFit.contain, aspect: null),
        VideoFit.fill => (fit: BoxFit.cover, aspect: null),
        VideoFit.ratio16x9 => (fit: BoxFit.fill, aspect: 16 / 9),
        VideoFit.ratio4x3 => (fit: BoxFit.fill, aspect: 4 / 3),
      };

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    final desktop = PlatformInfo.isDesktop;
    final fit = _fitFor(session.fit);

    final video = Video(
      controller: _ctrl.videoController,
      controls: NoVideoControls,
      fit: fit.fit,
      aspectRatio: fit.aspect,
      wakelock: false, // controlado pelo PlayerController
      pauseUponEnteringBackgroundMode: false, // tratado em app.dart (PiP)
      subtitleViewConfiguration: SubtitleViewConfiguration(
        style: TextStyle(
          fontSize: session.fullscreen ? 40 : (widget.compact ? 22 : 32),
          color: Colors.white,
          fontWeight: FontWeight.w500,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
          backgroundColor: Colors.black38,
        ),
        padding: EdgeInsets.only(
          bottom: _controlsVisible ? 72 : 24,
          left: 16,
          right: 16,
        ),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);

      Widget gestures;
      if (session.locked) {
        gestures = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _show(),
        );
      } else if (desktop) {
        gestures = Listener(
          onPointerSignal: _onPointerSignal,
          child: MouseRegion(
            cursor: _controlsVisible
                ? SystemMouseCursors.basic
                : SystemMouseCursors.none,
            onHover: (_) => _show(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _ctrl.togglePlay();
                _show();
              },
              onDoubleTap: _ctrl.toggleFullscreen,
            ),
          ),
        );
      } else {
        gestures = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onDoubleTapDown: (d) => _doubleTapPosition = d.localPosition,
          onDoubleTap: () => _onDoubleTap(size.width),
          onScaleStart: (d) => _onScaleStart(d, size),
          onScaleUpdate: (d) => _onScaleUpdate(d, size),
          onScaleEnd: _onScaleEnd,
        );
      }

      return ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            video,
            if (session.error != null) _ErrorOverlay(kind: session.error!),
            gestures,
            _BufferingIndicator(controller: _ctrl),
            if (_rippleSide != null)
              _SeekRipple(side: _rippleSide!, count: _rippleCount),
            if (_feedbackText != null)
              Center(child: _Feedback(icon: _feedbackIcon, text: _feedbackText!)),
            if (session.locked)
              _LockOverlay(
                visible: _controlsVisible,
                onUnlock: () => _ctrl.setLocked(false),
              )
            else
              IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: MouseRegion(
                    onHover: (_) => _show(),
                    child: PlayerControls(
                      onInteraction: _show,
                      onMinimize: widget.onMinimize,
                      compact: widget.compact,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

enum _DragKind { brightness, volume, minimize, pinch }

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator({required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: StreamBuilder<bool>(
        stream: controller.player.stream.buffering,
        initialData: controller.player.state.buffering,
        builder: (_, snap) => snap.data == true
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.kind});

  final PlayerErrorKind kind;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final unavailable = kind == PlayerErrorKind.unavailable;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                unavailable ? Icons.usb_off : Icons.error_outline,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                unavailable ? l.fileUnavailable : l.playerError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (!unavailable) ...[
                const SizedBox(height: 6),
                Text(
                  l.playerErrorDetail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.icon, required this.text});

  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

/// Animação de toque duplo (meia-lua com "10 s").
class _SeekRipple extends StatelessWidget {
  const _SeekRipple({required this.side, required this.count});

  final _Side side;
  final int count;

  @override
  Widget build(BuildContext context) {
    final left = side == _Side.left;
    return IgnorePointer(
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.38,
          heightFactor: 1,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(count),
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, v, child) => Opacity(opacity: v, child: child),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: left
                    ? const BorderRadius.horizontal(right: Radius.circular(400))
                    : const BorderRadius.horizontal(left: Radius.circular(400)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(left ? Icons.fast_rewind : Icons.fast_forward,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    '${left ? '−' : '+'}${count * 10} s',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay({required this.visible, required this.onUnlock});

  final bool visible;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: SafeArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  tooltip: context.l10n.unlockHint,
                  style: IconButton.styleFrom(backgroundColor: Colors.white24),
                  icon: const Icon(Icons.lock, color: Colors.white),
                  onPressed: visible ? onUnlock : null,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.unlockHint,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
