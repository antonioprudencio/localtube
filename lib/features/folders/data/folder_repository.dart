import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/video_extensions.dart';
import '../domain/library_diff.dart';

part 'folder_repository.g.dart';

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) =>
    FolderRepository(ref.watch(appDatabaseProvider));

/// Pasta com estatísticas agregadas.
class FolderSummary {
  const FolderSummary({
    required this.folder,
    required this.videoCount,
    required this.totalBytes,
  });

  final FolderRow folder;
  final int videoCount;
  final int totalBytes;
}

class FolderRepository {
  FolderRepository(this._db);

  final AppDatabase _db;

  Stream<List<FolderRow>> watchFolders() => (_db.select(_db.folders)
        ..orderBy([(f) => OrderingTerm.asc(f.name)]))
      .watch();

  Future<List<FolderRow>> getFolders() => _db.select(_db.folders).get();

  Future<FolderRow?> getFolder(int id) =>
      (_db.select(_db.folders)..where((f) => f.id.equals(id))).getSingleOrNull();

  Stream<FolderRow?> watchFolder(int id) =>
      (_db.select(_db.folders)..where((f) => f.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<FolderSummary>> watchSummaries() {
    final count = _db.videos.id.count(
        filter: _db.videos.isAvailable.equals(true));
    final size = _db.videos.sizeBytes.sum(
        filter: _db.videos.isAvailable.equals(true));
    final q = _db.select(_db.folders).join([
      leftOuterJoin(_db.videos, _db.videos.folderId.equalsExp(_db.folders.id),
          useColumns: false),
    ])
      ..addColumns([count, size])
      ..groupBy([_db.folders.id])
      ..orderBy([OrderingTerm.asc(_db.folders.name)]);
    return q.watch().map((rows) => rows
        .map((r) => FolderSummary(
              folder: r.readTable(_db.folders),
              videoCount: r.read(count) ?? 0,
              totalBytes: r.read(size) ?? 0,
            ))
        .toList());
  }

  /// Adiciona uma pasta (ou retorna a existente com o mesmo caminho).
  Future<FolderRow> addFolder(String path) async {
    final normalized = p.normalize(path);
    final existing = await (_db.select(_db.folders)
          ..where((f) => f.path.equals(normalized)))
        .getSingleOrNull();
    if (existing != null) return existing;
    final name = p.basename(normalized).isEmpty ? normalized : p.basename(normalized);
    return _db.into(_db.folders).insertReturning(
          FoldersCompanion.insert(path: normalized, name: name),
        );
  }

  Future<void> removeFolder(int id) =>
      (_db.delete(_db.folders)..where((f) => f.id.equals(id))).go();

  /// Snapshot dos vídeos já indexados de uma pasta, para o diff do scanner.
  Future<List<IndexedFile>> indexedFiles(int folderId) async {
    final rows = await (_db.select(_db.videos)
          ..where((v) => v.folderId.equals(folderId)))
        .get();
    return [
      for (final v in rows)
        IndexedFile(
          id: v.id,
          path: v.path,
          sizeBytes: v.sizeBytes,
          modifiedAt: v.modifiedAt,
          isAvailable: v.isAvailable,
        ),
    ];
  }

  Future<Set<String>> ignoredPaths() async =>
      (await _db.select(_db.ignoredPaths).get()).map((r) => r.path).toSet();

  /// Aplica o resultado do diff numa única transação.
  Future<void> applyDiff(int folderId, LibraryDiff diff) =>
      _db.transaction(() async {
        await _db.batch((b) {
          for (final f in diff.added) {
            b.insert(
              _db.videos,
              VideosCompanion.insert(
                folderId: folderId,
                path: f.path,
                fileName: p.basename(f.path),
                title: titleFromFileName(p.basename(f.path)),
                sizeBytes: f.sizeBytes,
                container: extensionOf(f.path),
                modifiedAt: f.modifiedAt,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
          for (final c in diff.changed) {
            b.update(
              _db.videos,
              VideosCompanion(
                sizeBytes: Value(c.file.sizeBytes),
                modifiedAt: Value(c.file.modifiedAt),
                isAvailable: const Value(true),
                // Força nova extração de metadados/miniatura.
                durationMs: const Value(null),
                thumbPath: const Value(null),
              ),
              where: (v) => v.id.equals(c.id),
            );
          }
          if (diff.restored.isNotEmpty) {
            b.update(
              _db.videos,
              const VideosCompanion(isAvailable: Value(true)),
              where: (v) => v.id.isIn(diff.restored),
            );
          }
          if (diff.missing.isNotEmpty) {
            b.update(
              _db.videos,
              const VideosCompanion(isAvailable: Value(false)),
              where: (v) => v.id.isIn(diff.missing),
            );
          }
        });
        await (_db.update(_db.folders)..where((f) => f.id.equals(folderId)))
            .write(FoldersCompanion(lastScanAt: Value(DateTime.now())));
      });

  /// Marca todos os vídeos da pasta como indisponíveis (pasta inacessível),
  /// preservando histórico e progresso.
  Future<void> markFolderUnavailable(int folderId) =>
      (_db.update(_db.videos)..where((v) => v.folderId.equals(folderId)))
          .write(const VideosCompanion(isAvailable: Value(false)));
}
