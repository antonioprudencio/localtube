import 'dart:io';

import 'package:flutter/foundation.dart';

import '../utils/video_extensions.dart';

/// Integrações com o shell do Windows.
abstract final class WindowsShell {
  /// Abre o Explorador de Arquivos com o arquivo selecionado.
  static Future<void> revealInExplorer(String path) async {
    if (!Platform.isWindows) return;
    await Process.run('explorer.exe', ['/select,', path]);
  }

  /// Registra o LocalTube no "Abrir com" para as extensões de vídeo
  /// (somente para o usuário atual — HKCU, sem precisar de administrador).
  static Future<bool> registerFileAssociations() async {
    if (!Platform.isWindows) return false;
    final exe = Platform.resolvedExecutable;
    const progId = 'LocalTube.Video';
    final commands = <List<String>>[
      ['HKCU\\Software\\Classes\\$progId', '/ve', '/d', 'Vídeo (LocalTube)'],
      ['HKCU\\Software\\Classes\\$progId\\DefaultIcon', '/ve', '/d', '"$exe",0'],
      [
        'HKCU\\Software\\Classes\\$progId\\shell\\open\\command',
        '/ve',
        '/d',
        '"$exe" "%1"',
      ],
      [
        'HKCU\\Software\\Classes\\Applications\\LocalTube.exe\\shell\\open\\command',
        '/ve',
        '/d',
        '"$exe" "%1"',
      ],
      [
        'HKCU\\Software\\Classes\\Applications\\LocalTube.exe',
        '/v',
        'FriendlyAppName',
        '/d',
        'LocalTube',
      ],
      for (final ext in kVideoExtensions) ...[
        [
          'HKCU\\Software\\Classes\\.$ext\\OpenWithProgids',
          '/v',
          progId,
          '/t',
          'REG_NONE',
        ],
        [
          'HKCU\\Software\\Classes\\Applications\\LocalTube.exe\\SupportedTypes',
          '/v',
          '.$ext',
          '/d',
          '',
        ],
      ],
    ];
    try {
      for (final args in commands) {
        final r = await Process.run('reg', ['add', ...args, '/f']);
        if (r.exitCode != 0) {
          debugPrint('[WindowsShell] reg add falhou: ${r.stderr}');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[WindowsShell] erro: $e');
      return false;
    }
  }
}
