import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../../../core/utils/video_extensions.dart';
import '../domain/library_diff.dart';

/// Resultado do scan de uma pasta.
class ScanResult {
  const ScanResult({required this.rootExists, required this.files});

  /// `false` quando a pasta não está acessível (ex.: unidade USB/rede
  /// desconectada). Nesse caso, nada deve ser apagado do banco.
  final bool rootExists;
  final List<ScannedFile> files;
}

/// Opções do scan (precisam ser enviáveis para outro Isolate).
class ScanOptions {
  const ScanOptions({
    required this.root,
    this.extensions = kVideoExtensions,
    this.minSizeBytes = 0,
  });

  final String root;
  final List<String> extensions;
  final int minSizeBytes;
}

/// Escaneia a pasta recursivamente em um Isolate separado, sem bloquear a UI.
Future<ScanResult> scanFolder(ScanOptions options) =>
    Isolate.run(() => scanFolderSync(options));

/// Implementação síncrona (exposta para testes).
ScanResult scanFolderSync(ScanOptions options) {
  final root = Directory(_longPath(options.root));
  if (!root.existsSync()) {
    return const ScanResult(rootExists: false, files: []);
  }
  final exts = options.extensions.toSet();
  final files = <ScannedFile>[];
  _walk(root, exts, options.minSizeBytes, files);
  return ScanResult(rootExists: true, files: files);
}

void _walk(Directory dir, Set<String> exts, int minSize, List<ScannedFile> out) {
  final List<FileSystemEntity> entries;
  try {
    entries = dir.listSync(followLinks: false);
  } on FileSystemException {
    return; // Sem permissão ou pasta removida durante o scan.
  }

  // Pastas com `.nomedia` são ignoradas (convenção do Android).
  if (entries.any((e) => e is File && p.basename(e.path) == '.nomedia')) {
    return;
  }

  for (final e in entries) {
    final name = p.basename(e.path);
    if (e is Directory) {
      if (_shouldSkipDir(e.path, name)) continue;
      _walk(e, exts, minSize, out);
    } else if (e is File) {
      if (name.startsWith('.')) continue;
      if (!exts.contains(extensionOf(name))) continue;
      try {
        final stat = e.statSync();
        if (stat.size < minSize) continue;
        out.add(ScannedFile(
          path: _shortPath(e.path),
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
        ));
      } on FileSystemException {
        continue;
      }
    }
  }
}

bool _shouldSkipDir(String path, String name) {
  if (name.startsWith('.')) return true;
  final normalized = path.replaceAll('\\', '/').toLowerCase();
  // Android: dados privados de outros apps.
  if (normalized.contains('/android/data') ||
      normalized.contains('/android/obb')) {
    return true;
  }
  // Windows: pastas de sistema.
  const winSkip = {r'$recycle.bin', 'system volume information'};
  return winSkip.contains(name.toLowerCase());
}

/// No Windows, usa o prefixo `\\?\` para suportar caminhos > 260 caracteres.
String _longPath(String path) {
  if (!Platform.isWindows) return path;
  if (path.startsWith(r'\\?\')) return path;
  final abs = p.absolute(path);
  if (abs.startsWith(r'\\')) return r'\\?\UNC\' + abs.substring(2);
  return r'\\?\' + abs;
}

String _shortPath(String path) {
  if (!Platform.isWindows) return path;
  if (path.startsWith(r'\\?\UNC\')) return r'\\' + path.substring(8);
  if (path.startsWith(r'\\?\')) return path.substring(4);
  return path;
}
