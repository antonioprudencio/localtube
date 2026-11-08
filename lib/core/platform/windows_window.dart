import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Integração com a janela nativa no Windows (título, tamanho mínimo e
/// tela cheia), usando a API nativa do window_manager 0.6+.
/// Em outras plataformas, as chamadas viram no-op.
abstract final class WindowsWindow {
  static const appTitle = 'LocalTube';

  static Window? get _window {
    if (!Platform.isWindows) return null;
    try {
      return WindowManager.instance.getCurrent();
    } catch (e) {
      debugPrint('[WindowsWindow] janela indisponível: $e');
      return null;
    }
  }

  static void init() {
    final w = _window;
    if (w == null) return;
    w.title = appTitle;
    w.minimumSize = const Size(800, 560).toNative();
    w.setSize(const Size(1280, 760).toNative(), false);
    w.center();
    w.show();
    w.focus();
  }

  /// Título: "nome do vídeo — LocalTube", ou só "LocalTube".
  static void setVideoTitle(String? videoTitle) {
    _window?.title = videoTitle == null ? appTitle : '$videoTitle — $appTitle';
  }

  static bool get isFullScreen => _window?.isFullScreen ?? false;

  static void setFullScreen(bool value) {
    _window?.isFullScreen = value;
  }
}
