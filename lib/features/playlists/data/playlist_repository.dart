import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../../../core/providers.dart';

part 'playlist_repository.g.dart';

@Riverpod(keepAlive: true)
PlaylistRepository playlistRepository(Ref ref) =>
    PlaylistRepository(ref.watch(appDatabaseProvider));

class PlaylistSummary {
  const PlaylistSummary({
    required this.playlist,
    required this.itemCount,
    this.coverThumb,
  });

  final PlaylistRow playlist;
  final int itemCount;

  /// Miniatura do primeiro vídeo (capa da playlist).
  final String? coverThumb;
}

class PlaylistRepository {
  PlaylistRepository(this._db);

  final AppDatabase _db;

  Stream<List<PlaylistSummary>> watchPlaylists() {
    final count = _db.playlistItems.videoId.count();
    final q = _db.select(_db.playlists).join([
      leftOuterJoin(_db.playlistItems,
          _db.playlistItems.playlistId.equalsExp(_db.playlists.id),
          useColumns: false),
    ])
      ..addColumns([count])
      ..groupBy([_db.playlists.id])
      ..orderBy([OrderingTerm.desc(_db.playlists.createdAt)]);

    return q.watch().asyncMap((rows) async {
      final result = <PlaylistSummary>[];
      for (final r in rows) {
        final pl = r.readTable(_db.playlists);
        result.add(PlaylistSummary(
          playlist: pl,
          itemCount: r.read(count) ?? 0,
          coverThumb: await _coverThumb(pl.id),
        ));
      }
      return result;
    });
  }

  Future<String?> _coverThumb(int playlistId) async {
    final q = _db.select(_db.playlistItems).join([
      innerJoin(_db.videos, _db.videos.id.equalsExp(_db.playlistItems.videoId)),
    ])
      ..where(_db.playlistItems.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(_db.playlistItems.position)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row?.readTable(_db.videos).thumbPath;
  }

  Stream<PlaylistRow?> watchPlaylist(int id) =>
      (_db.select(_db.playlists)..where((p) => p.id.equals(id)))
          .watchSingleOrNull();

  Future<List<PlaylistRow>> getPlaylists() => (_db.select(_db.playlists)
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .get();

  Stream<List<VideoItem>> watchItems(int playlistId) {
    final q = _db.select(_db.playlistItems).join([
      innerJoin(_db.videos, _db.videos.id.equalsExp(_db.playlistItems.videoId)),
      innerJoin(_db.folders, _db.folders.id.equalsExp(_db.videos.folderId)),
      leftOuterJoin(_db.playbackState,
          _db.playbackState.videoId.equalsExp(_db.videos.id)),
    ])
      ..where(_db.playlistItems.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(_db.playlistItems.position)]);
    return q.watch().map((rows) => [
          for (final r in rows)
            VideoItem(
              video: r.readTable(_db.videos),
              folderName: r.readTable(_db.folders).name,
              playback: r.readTableOrNull(_db.playbackState),
            ),
        ]);
  }

  /// IDs das playlists que contêm o vídeo.
  Future<Set<int>> playlistsContaining(int videoId) async {
    final rows = await (_db.select(_db.playlistItems)
          ..where((i) => i.videoId.equals(videoId)))
        .get();
    return rows.map((r) => r.playlistId).toSet();
  }

  Future<PlaylistRow> create(String name) => _db
      .into(_db.playlists)
      .insertReturning(PlaylistsCompanion.insert(name: name.trim()));

  Future<void> rename(int id, String name) =>
      (_db.update(_db.playlists)..where((p) => p.id.equals(id)))
          .write(PlaylistsCompanion(name: Value(name.trim())));

  Future<void> delete(int id) =>
      (_db.delete(_db.playlists)..where((p) => p.id.equals(id))).go();

  /// Adiciona ao fim da playlist (ignora se já estiver nela).
  Future<void> addVideo(int playlistId, int videoId) async {
    final maxPos = _db.playlistItems.position.max();
    final q = _db.selectOnly(_db.playlistItems)
      ..addColumns([maxPos])
      ..where(_db.playlistItems.playlistId.equals(playlistId));
    final current = await q.map((r) => r.read(maxPos)).getSingle();
    await _db.into(_db.playlistItems).insert(
          PlaylistItemsCompanion.insert(
            playlistId: playlistId,
            videoId: videoId,
            position: (current ?? -1) + 1,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeVideo(int playlistId, int videoId) =>
      (_db.delete(_db.playlistItems)
            ..where((i) =>
                i.playlistId.equals(playlistId) & i.videoId.equals(videoId)))
          .go();

  /// Grava a nova ordem dos itens (lista completa de IDs de vídeo).
  Future<void> reorder(int playlistId, List<int> videoIds) =>
      _db.batch((b) {
        for (var i = 0; i < videoIds.length; i++) {
          b.update(
            _db.playlistItems,
            PlaylistItemsCompanion(position: Value(i)),
            where: (t) =>
                t.playlistId.equals(playlistId) & t.videoId.equals(videoIds[i]),
          );
        }
      });
}
