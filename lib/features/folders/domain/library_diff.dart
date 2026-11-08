/// Arquivo encontrado no disco pelo scanner.
class ScannedFile {
  const ScannedFile({
    required this.path,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  final String path;
  final int sizeBytes;
  final DateTime modifiedAt;

  @override
  bool operator ==(Object other) =>
      other is ScannedFile &&
      other.path == path &&
      other.sizeBytes == sizeBytes &&
      other.modifiedAt == modifiedAt;

  @override
  int get hashCode => Object.hash(path, sizeBytes, modifiedAt);

  @override
  String toString() => 'ScannedFile($path, $sizeBytes)';
}

/// Vídeo já indexado no banco (snapshot mínimo para comparação).
class IndexedFile {
  const IndexedFile({
    required this.id,
    required this.path,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.isAvailable,
  });

  final int id;
  final String path;
  final int sizeBytes;
  final DateTime modifiedAt;
  final bool isAvailable;
}

class ChangedFile {
  const ChangedFile(this.id, this.file);
  final int id;
  final ScannedFile file;
}

/// Resultado da comparação entre disco e banco.
class LibraryDiff {
  const LibraryDiff({
    this.added = const [],
    this.changed = const [],
    this.missing = const [],
    this.restored = const [],
  });

  /// Arquivos novos.
  final List<ScannedFile> added;

  /// Arquivos cujo tamanho ou data de modificação mudou.
  final List<ChangedFile> changed;

  /// IDs que estavam disponíveis e não foram encontrados.
  final List<int> missing;

  /// IDs que estavam indisponíveis e reapareceram sem alteração.
  final List<int> restored;

  bool get isEmpty =>
      added.isEmpty && changed.isEmpty && missing.isEmpty && restored.isEmpty;
}

/// Compara o resultado do scan com o que já está no banco.
///
/// A identidade é o caminho; mudança é detectada por tamanho + data de
/// modificação (com tolerância de 2 s para sistemas FAT/exFAT).
/// Arquivos sumidos são apenas marcados como indisponíveis, preservando
/// histórico, favoritos e progresso (ex.: pendrive desconectado).
LibraryDiff computeLibraryDiff({
  required List<ScannedFile> scanned,
  required List<IndexedFile> indexed,
  Set<String> ignored = const {},
}) {
  final byPath = {for (final i in indexed) _key(i.path): i};
  final seen = <String>{};
  final added = <ScannedFile>[];
  final changed = <ChangedFile>[];
  final restored = <int>[];

  for (final f in scanned) {
    final key = _key(f.path);
    if (ignored.contains(f.path)) continue;
    if (!seen.add(key)) continue;
    final existing = byPath[key];
    if (existing == null) {
      added.add(f);
      continue;
    }
    final modifiedDelta =
        existing.modifiedAt.difference(f.modifiedAt).inSeconds.abs();
    if (existing.sizeBytes != f.sizeBytes || modifiedDelta > 2) {
      changed.add(ChangedFile(existing.id, f));
    } else if (!existing.isAvailable) {
      restored.add(existing.id);
    }
  }

  final missing = [
    for (final i in indexed)
      if (i.isAvailable && !seen.contains(_key(i.path))) i.id,
  ];

  return LibraryDiff(
    added: added,
    changed: changed,
    missing: missing,
    restored: restored,
  );
}

String _key(String path) => path;
