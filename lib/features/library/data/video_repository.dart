import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../../../core/providers.dart';

part 'video_repository.g.dart';

@Riverpod(keepAlive: true)
VideoRepository videoRepository(Ref ref) =>
    VideoRepository(ref.watch(appDatabaseProvider));

/// Metadados extraídos de um arquivo pelo player.
class VideoMetadata {
  const VideoMetadata({
    required this.durationMs,
    this.width,
    this.height,
    this.videoCodec,
    this.audioCodec,
    this.thumbPath,
  });

  final int durationMs;
  final int? width;
  final int? height;
  final String? videoCodec;
  final String? audioCodec;
  final String? thumbPath;
}

/// Acesso aos vídeos da biblioteca (consultas reativas para a UI).
class VideoRepository {
  VideoRepository(this._db);

  final AppDatabase _db;

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    return _db.select(_db.videos).join([
      innerJoin(_db.folders, _db.folders.id.equalsExp(_db.videos.folderId)),
      leftOuterJoin(_db.playbackState,
          _db.playbackState.videoId.equalsExp(_db.videos.id)),
    ]);
  }

  VideoItem _map(TypedResult row) => VideoItem(
        video: row.readTable(_db.videos),
        folderName: row.readTable(_db.folders).name,
        playback: row.readTableOrNull(_db.playbackState),
      );

  Stream<List<VideoItem>> _watch(
    JoinedSelectStatement<HasResultSet, dynamic> q,
  ) =>
      q.watch().map((rows) => rows.map(_map).toList());

  /// Todos os vídeos disponíveis, mais recentes primeiro.
  Stream<List<VideoItem>> watchAll({int? folderId}) {
    final q = _joined()..where(_db.videos.isAvailable.equals(true));
    if (folderId != null) q.where(_db.videos.folderId.equals(folderId));
    q.orderBy([
      OrderingTerm.desc(_db.videos.modifiedAt),
      OrderingTerm.asc(_db.videos.title),
    ]);
    return _watch(q);
  }

  /// Vídeos de uma pasta em ordem alfabética (usado na lista "A seguir").
  Future<List<VideoItem>> folderVideos(int folderId) {
    final q = _joined()
      ..where(_db.videos.folderId.equals(folderId) &
          _db.videos.isAvailable.equals(true))
      ..orderBy([OrderingTerm.asc(_db.videos.path)]);
    return q.get().then((r) => r.map(_map).toList());
  }

  Stream<List<VideoItem>> watchContinueWatching({int limit = 20}) {
    final q = _joined()
      ..where(_db.videos.isAvailable.equals(true) &
          _db.playbackState.completed.equals(false) &
          _db.playbackState.positionMs.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.desc(_db.playbackState.lastPlayedAt)])
      ..limit(limit);
    return _watch(q);
  }

  /// Histórico: inclui vídeos indisponíveis (ex.: unidade desconectada).
  Stream<List<VideoItem>> watchHistory() {
    final q = _joined()
      ..where(_db.playbackState.lastPlayedAt.isNotNull())
      ..orderBy([OrderingTerm.desc(_db.playbackState.lastPlayedAt)]);
    return _watch(q);
  }

  Stream<List<VideoItem>> watchFavorites() {
    final q = _joined()
      ..where(_db.videos.isFavorite.equals(true))
      ..orderBy([OrderingTerm.asc(_db.videos.title)]);
    return _watch(q);
  }

  Stream<List<VideoItem>> watchWatchLater() {
    final q = _joined()
      ..where(_db.videos.watchLater.equals(true))
      ..orderBy([OrderingTerm.asc(_db.videos.title)]);
    return _watch(q);
  }

  Stream<VideoItem?> watchById(int id) {
    final q = _joined()..where(_db.videos.id.equals(id));
    return q.watchSingleOrNull().map((r) => r == null ? null : _map(r));
  }

  Future<VideoItem?> getById(int id) async {
    final q = _joined()..where(_db.videos.id.equals(id));
    final r = await q.getSingleOrNull();
    return r == null ? null : _map(r);
  }

  Future<VideoItem?> getByPath(String path) async {
    final q = _joined()..where(_db.videos.path.equals(path));
    final r = await q.getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Busca por nome do arquivo, título ou nome da pasta (sem diferenciar
  /// maiúsculas/minúsculas).
  Future<List<VideoItem>> search(String term, {int limit = 200}) {
    final t = term.trim().toLowerCase();
    if (t.isEmpty) return Future.value(const []);
    final pattern = '%${t.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final q = _joined()
      ..where(_db.videos.isAvailable.equals(true) &
          (_db.videos.title.lower().like(pattern) |
              _db.videos.fileName.lower().like(pattern) |
              _db.folders.name.lower().like(pattern)))
      ..orderBy([OrderingTerm.asc(_db.videos.title)])
      ..limit(limit);
    return q.get().then((r) => r.map(_map).toList());
  }

  Future<void> setFavorite(int id, bool value) =>
      (_db.update(_db.videos)..where((v) => v.id.equals(id)))
          .write(VideosCompanion(isFavorite: Value(value)));

  Future<void> setWatchLater(int id, bool value) =>
      (_db.update(_db.videos)..where((v) => v.id.equals(id)))
          .write(VideosCompanion(watchLater: Value(value)));

  /// Remove da biblioteca e impede que o scanner o adicione de novo.
  Future<void> removeFromLibrary(int id) => _db.transaction(() async {
        final v = await (_db.select(_db.videos)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (v == null) return;
        await _db
            .into(_db.ignoredPaths)
            .insertOnConflictUpdate(IgnoredPathsCompanion.insert(path: v.path));
        await (_db.delete(_db.videos)..where((t) => t.id.equals(id))).go();
      });

  /// Vídeos ainda sem metadados extraídos.
  Future<List<VideoRow>> pendingProbe({int limit = 50}) =>
      (_db.select(_db.videos)
            ..where((v) => v.durationMs.isNull() & v.isAvailable.equals(true))
            ..orderBy([(v) => OrderingTerm.desc(v.modifiedAt)])
            ..limit(limit))
          .get();

  Future<void> saveMetadata(int id, VideoMetadata m) =>
      (_db.update(_db.videos)..where((v) => v.id.equals(id))).write(
        VideosCompanion(
          durationMs: Value(m.durationMs),
          width: Value(m.width),
          height: Value(m.height),
          videoCodec: Value(m.videoCodec),
          audioCodec: Value(m.audioCodec),
          thumbPath: Value(m.thumbPath),
        ),
      );

  /// Apaga referências às miniaturas e força nova extração.
  Future<void> resetThumbnails() => _db.update(_db.videos).write(
        const VideosCompanion(thumbPath: Value(null), durationMs: Value(null)),
      );

  /// Contêineres distintos presentes na biblioteca (para os chips de filtro).
  Stream<List<String>> watchContainers() {
    final c = _db.videos.container;
    final q = _db.selectOnly(_db.videos, distinct: true)
      ..addColumns([c])
      ..where(_db.videos.isAvailable.equals(true))
      ..orderBy([OrderingTerm.asc(c)]);
    return q.watch().map((rows) => rows.map((r) => r.read(c)!).toList());
  }
}
