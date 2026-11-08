import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

import '../../library/data/video_repository.dart';

/// Extrai metadados (duração, resolução, codecs) e gera a miniatura de um
/// vídeo usando um [Player] oculto do media_kit.
///
/// Cada instância mantém um único player reaproveitado entre arquivos; para
/// concorrência, crie várias instâncias (ver `LibraryIndexer`).
class MediaProbe {
  MediaProbe({required this.thumbsDir});

  final String thumbsDir;

  Player? _player;
  // Mantém o controller vivo enquanto o player existir (necessário para
  // que o mpv tenha saída de vídeo e o screenshot funcione).
  // ignore: unused_field
  VideoController? _controller;

  static const _openTimeout = Duration(seconds: 10);
  static const _thumbWidth = 480;

  Future<void> _ensurePlayer() async {
    if (_player != null) return;
    final player = Player(
      configuration: const PlayerConfiguration(
        muted: true,
        title: 'LocalTube (miniaturas)',
        logLevel: MPVLogLevel.error,
      ),
    );
    // O controller é necessário para que o mpv decodifique frames de vídeo
    // (screenshot). Decodificação por software evita problemas com texturas
    // de hardware em players ocultos.
    _controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        width: 640,
        height: 360,
        enableHardwareAcceleration: false,
      ),
    );
    _player = player;
    if (player.platform case final NativePlayer native) {
      // Não carregar legendas nem áudio durante a extração.
      await native.setProperty('sid', 'no');
      await native.setProperty('aid', 'no');
      // Busca no keyframe mais próximo (sem decodificar até o ponto exato):
      // muito mais barato em vídeos 4K/AV1 decodificados por software.
      await native.setProperty('hr-seek', 'no');
      // Atalhos de decodificação: a miniatura não precisa de qualidade máxima.
      await native.setProperty('vd-lavc-skiploopfilter', 'all');
      await native.setProperty('vd-lavc-fast', 'yes');
      await native.setProperty('cache', 'no');
    }
  }

  Future<VideoMetadata> probe({required int videoId, required String path}) async {
    await _ensurePlayer();
    final player = _player!;
    final errors = <String>[];
    final errorSub = player.stream.error.listen(errors.add);

    try {
      await player.open(Media(path), play: false);

      final duration = player.state.duration > Duration.zero
          ? player.state.duration
          : await player.stream.duration
              .firstWhere((d) => d > Duration.zero)
              .timeout(_openTimeout);

      // Aguarda as faixas e as dimensões serem reportadas.
      if ((player.state.width ?? 0) == 0) {
        await player.stream.width
            .firstWhere((w) => (w ?? 0) > 0)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
      }

      final videoTrack = player.state.tracks.video
          .where((t) => t.id != 'auto' && t.id != 'no')
          .firstOrNull;
      final audioTrack = player.state.tracks.audio
          .where((t) => t.id != 'auto' && t.id != 'no')
          .firstOrNull;

      String? thumbPath;
      if (videoTrack != null || (player.state.width ?? 0) > 0) {
        thumbPath = await _captureThumb(player, videoId, duration);
      }

      return VideoMetadata(
        durationMs: duration.inMilliseconds,
        width: player.state.width ?? videoTrack?.w,
        height: player.state.height ?? videoTrack?.h,
        videoCodec: videoTrack?.codec,
        audioCodec: audioTrack?.codec,
        thumbPath: thumbPath,
      );
    } on TimeoutException {
      debugPrint('[MediaProbe] timeout: $path ${errors.join('; ')}');
      return const VideoMetadata(durationMs: 0);
    } catch (e) {
      debugPrint('[MediaProbe] falha em $path: $e');
      return const VideoMetadata(durationMs: 0);
    } finally {
      await errorSub.cancel();
      try {
        await player.stop();
      } catch (_) {}
    }
  }

  Future<String?> _captureThumb(Player player, int id, Duration duration) async {
    try {
      final target = duration * 0.1;
      await player.seek(target);
      // Espera o frame do ponto de busca ser decodificado.
      await player.stream.position
          .firstWhere((pos) => (pos - target).inSeconds.abs() < 15)
          .timeout(const Duration(seconds: 3), onTimeout: () => target);
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final bytes = await player.screenshot(format: 'image/jpeg');
      if (bytes == null || bytes.isEmpty) return null;

      final out = p.join(thumbsDir, '$id.jpg');
      final ok = await Isolate.run(() => _resizeAndSave(bytes, out, _thumbWidth));
      return ok ? out : null;
    } catch (e) {
      debugPrint('[MediaProbe] miniatura falhou ($id): $e');
      return null;
    }
  }

  Future<void> dispose() async {
    final player = _player;
    _player = null;
    _controller = null;
    await player?.dispose();
  }
}

bool _resizeAndSave(Uint8List bytes, String outPath, int width) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return false;
  final resized = decoded.width > width
      ? img.copyResize(decoded, width: width, interpolation: img.Interpolation.average)
      : decoded;
  File(outPath)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(img.encodeJpg(resized, quality: 80));
  return true;
}
