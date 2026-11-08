import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// Barra de busca com buffer, prévia de tempo ao arrastar e (no desktop)
/// ao passar o mouse.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.player,
    required this.onSeek,
    this.onInteraction,
  });

  final Player player;
  final ValueChanged<Duration> onSeek;

  /// Chamado durante a interação (para manter os controles visíveis).
  final VoidCallback? onInteraction;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  late Duration _position = widget.player.state.position;
  late Duration _duration = widget.player.state.duration;
  late Duration _buffer = widget.player.state.buffer;
  final _subs = <StreamSubscription<Duration>>[];

  double? _dragValue; // 0–1 enquanto arrasta
  double? _hoverValue; // 0–1 com o mouse em cima
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    final s = widget.player.stream;
    _subs
      ..add(s.position.listen((p) {
        if (_dragValue == null && mounted) setState(() => _position = p);
      }))
      ..add(s.duration.listen((d) => mounted ? setState(() => _duration = d) : null))
      ..add(s.buffer.listen((b) => mounted ? setState(() => _buffer = b) : null));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  double _fraction(Duration d) => _duration.inMilliseconds <= 0
      ? 0
      : (d.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

  Duration _at(double f) => _duration * f;

  double _valueFromDx(double dx, double width) => (dx / width).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final played = _dragValue ?? _fraction(_position);
    final buffered = _fraction(_buffer);
    final preview = _dragValue ?? (_hovering ? _hoverValue : null);
    final active = _dragValue != null || _hovering;

    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() {
          _hovering = false;
          _hoverValue = null;
        }),
        onHover: (e) {
          setState(() => _hoverValue = _valueFromDx(e.localPosition.dx, width));
          widget.onInteraction?.call();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            setState(() => _dragValue = _valueFromDx(d.localPosition.dx, width));
            widget.onInteraction?.call();
          },
          onHorizontalDragUpdate: (d) {
            setState(() => _dragValue = _valueFromDx(d.localPosition.dx, width));
            widget.onInteraction?.call();
          },
          onHorizontalDragEnd: (_) {
            final v = _dragValue;
            if (v != null) {
              _position = _at(v);
              widget.onSeek(_position);
            }
            setState(() => _dragValue = null);
          },
          onTapUp: (d) {
            final v = _valueFromDx(d.localPosition.dx, width);
            _position = _at(v);
            widget.onSeek(_position);
            setState(() {});
          },
          child: Semantics(
            slider: true,
            label: 'Posição',
            value: Fmt.duration(_position),
            child: SizedBox(
              height: 32,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  _track(width, 1, Colors.white24, active),
                  _track(width, buffered, Colors.white54, active),
                  _track(width, played, AppTheme.accent, active),
                  Positioned(
                    left: (played * width - 7).clamp(-7.0, width - 7),
                    child: AnimatedScale(
                      scale: active ? 1 : 0.0001,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  if (preview != null)
                    Positioned(
                      left: (preview * width - 32).clamp(0.0, width - 64),
                      bottom: 26,
                      child: Container(
                        width: 64,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          Fmt.duration(_at(preview)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _track(double width, double fraction, Color color, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: width * fraction,
      height: active ? 5 : 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
