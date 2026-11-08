import 'package:path/path.dart' as p;

/// Extensões de vídeo suportadas (sem ponto, minúsculas).
const kVideoExtensions = <String>[
  'mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'wmv', 'm4v', '3gp', 'ts',
  'm2ts', 'mpg', 'mpeg', 'ogv',
];

/// Extensões de legenda externa, em ordem de preferência.
const kSubtitleExtensions = <String>['srt', 'ass', 'ssa', 'vtt'];

String extensionOf(String path) {
  final ext = p.extension(path);
  return ext.isEmpty ? '' : ext.substring(1).toLowerCase();
}

bool isVideoFile(String path, {Iterable<String> allowed = kVideoExtensions}) =>
    allowed.contains(extensionOf(path));

/// Título amigável a partir do nome do arquivo: remove extensão e troca
/// separadores comuns ("_" e ".") por espaço.
String titleFromFileName(String fileName) {
  final base = p.basenameWithoutExtension(fileName);
  return base.replaceAll(RegExp(r'[._]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
