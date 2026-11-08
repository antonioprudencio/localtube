import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../domain/player_controller.dart';

/// Atalhos de teclado do player (estilo YouTube) + teclas de mídia.
///
/// K/Espaço play/pause · J/L ±10 s · ←/→ ±5 s · ↑/↓ volume · F tela cheia ·
/// M mudo · C legendas · 0–9 pular para 0–90 % · Shift+N/P próximo/anterior ·
/// < > velocidade · Esc sair da tela cheia · Ctrl+F busca.
class PlayerShortcuts extends ConsumerWidget {
  const PlayerShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handle(context, ref, event),
      child: child,
    );
  }

  KeyEventResult _handle(BuildContext context, WidgetRef ref, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final ctrl = ref.read(playerControllerProvider.notifier);
    final keyboard = HardwareKeyboard.instance;
    final shift = keyboard.isShiftPressed;
    final ctrlKey = keyboard.isControlPressed || keyboard.isMetaPressed;
    final key = event.logicalKey;
    final char = event.character;
    final isRepeat = event is KeyRepeatEvent;

    // Teclas que não devem repetir ao segurar.
    bool once(VoidCallback f) {
      if (!isRepeat) f();
      return true;
    }

    final handled = switch (key) {
      _ when ctrlKey && key == LogicalKeyboardKey.keyF => once(() {
          ctrl.exitFullscreen();
          context.push(Routes.search);
        }),
      _ when ctrlKey => false,
      _ when char == '<' => once(() => ctrl.stepRate(-1)),
      _ when char == '>' => once(() => ctrl.stepRate(1)),
      LogicalKeyboardKey.keyN when shift => once(ctrl.next),
      LogicalKeyboardKey.keyP when shift => once(ctrl.previous),
      LogicalKeyboardKey.keyK ||
      LogicalKeyboardKey.space ||
      LogicalKeyboardKey.mediaPlayPause =>
        once(ctrl.togglePlay),
      LogicalKeyboardKey.mediaPlay => once(ctrl.player.play),
      LogicalKeyboardKey.mediaPause => once(ctrl.player.pause),
      LogicalKeyboardKey.mediaTrackNext => once(ctrl.next),
      LogicalKeyboardKey.mediaTrackPrevious => once(ctrl.previous),
      LogicalKeyboardKey.mediaStop => once(ctrl.player.pause),
      LogicalKeyboardKey.keyJ =>
        _do(() => ctrl.seekRelative(const Duration(seconds: -10))),
      LogicalKeyboardKey.keyL =>
        _do(() => ctrl.seekRelative(const Duration(seconds: 10))),
      LogicalKeyboardKey.arrowLeft =>
        _do(() => ctrl.seekRelative(const Duration(seconds: -5))),
      LogicalKeyboardKey.arrowRight =>
        _do(() => ctrl.seekRelative(const Duration(seconds: 5))),
      LogicalKeyboardKey.arrowUp => _do(() => ctrl.changeVolume(5)),
      LogicalKeyboardKey.arrowDown => _do(() => ctrl.changeVolume(-5)),
      LogicalKeyboardKey.keyF => once(ctrl.toggleFullscreen),
      LogicalKeyboardKey.keyM => once(ctrl.toggleMute),
      LogicalKeyboardKey.keyC => once(ctrl.toggleSubtitles),
      LogicalKeyboardKey.escape =>
        ref.read(playerControllerProvider).fullscreen
            ? once(ctrl.exitFullscreen)
            : false,
      _ => _digit(key, ctrl, isRepeat),
    };
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  static bool _do(VoidCallback f) {
    f();
    return true;
  }

  static const _digits = [
    LogicalKeyboardKey.digit0, LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4, LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6, LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8, LogicalKeyboardKey.digit9,
  ];

  static const _numpad = [
    LogicalKeyboardKey.numpad0, LogicalKeyboardKey.numpad1,
    LogicalKeyboardKey.numpad2, LogicalKeyboardKey.numpad3,
    LogicalKeyboardKey.numpad4, LogicalKeyboardKey.numpad5,
    LogicalKeyboardKey.numpad6, LogicalKeyboardKey.numpad7,
    LogicalKeyboardKey.numpad8, LogicalKeyboardKey.numpad9,
  ];

  static bool _digit(LogicalKeyboardKey key, PlayerController ctrl, bool repeat) {
    var i = _digits.indexOf(key);
    if (i < 0) i = _numpad.indexOf(key);
    if (i < 0) return false;
    if (!repeat) ctrl.seekFraction(i / 10);
    return true;
  }
}
