import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Recursos específicos do Android: Picture-in-Picture (via MainActivity),
/// modo imersivo/orientação para tela cheia e brilho da tela.
abstract final class AndroidSystem {
  static const _channel = MethodChannel('com.localtube.app/system');

  static final _pipController = StreamController<bool>.broadcast();
  static bool _initialized = false;

  /// Emite `true`/`false` quando o app entra/sai do modo PiP.
  static Stream<bool> get pipChanges {
    _ensureInit();
    return _pipController.stream;
  }

  static void _ensureInit() {
    if (_initialized || !Platform.isAndroid) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged') {
        _pipController.add(call.arguments == true);
      }
    });
  }

  /// Habilita/desabilita a entrada automática em PiP ao sair do app
  /// (quando há vídeo tocando).
  static Future<void> setAutoPip(bool enabled) async {
    if (!Platform.isAndroid) return;
    _ensureInit();
    try {
      await _channel.invokeMethod('setAutoPip', enabled);
    } on PlatformException catch (e) {
      debugPrint('[AndroidSystem] setAutoPip: $e');
    }
  }

  static Future<bool> enterPip({int width = 16, int height = 9}) async {
    if (!Platform.isAndroid) return false;
    _ensureInit();
    try {
      return await _channel.invokeMethod<bool>(
              'enterPip', {'width': width, 'height': height}) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('[AndroidSystem] enterPip: $e');
      return false;
    }
  }

  static Future<void> enterFullscreen({bool landscape = true}) async {
    if (!Platform.isAndroid) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (landscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  static Future<void> exitFullscreen() async {
    if (!Platform.isAndroid) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([]);
  }

  static Future<double> brightness() async {
    try {
      return await ScreenBrightness.instance.application;
    } catch (_) {
      return 0.5;
    }
  }

  static Future<void> setBrightness(double value) async {
    if (!Platform.isAndroid) return;
    try {
      await ScreenBrightness.instance
          .setApplicationScreenBrightness(value.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('[AndroidSystem] brilho: $e');
    }
  }

  static Future<void> resetBrightness() async {
    if (!Platform.isAndroid) return;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }
}
