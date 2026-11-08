import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';

part 'playback_repository.g.dart';

@Riverpod(keepAlive: true)
PlaybackRepository playbackRepository(Ref ref) =>
    PlaybackRepository(ref.watch(appDatabaseProvider));

/// Persiste posição, conclusão e preferências de reprodução por vídeo.
class PlaybackRepository {
  PlaybackRepository(this._db);

  final AppDatabase _db;

  /// Acima desta fração o vídeo é considerado concluído.
  static const completedThreshold = 0.95;

  Future<PlaybackStateRow?> get(int videoId) =>
      (_db.select(_db.playbackState)..where((p) => p.videoId.equals(videoId)))
          .getSingleOrNull();

  /// Registra o início de uma reprodução (incrementa contagem e data).
  Future<void> markStarted(int videoId) async {
    final existing = await get(videoId);
    await _db.into(_db.playbackState).insertOnConflictUpdate(
          PlaybackStateCompanion(
            videoId: Value(videoId),
            lastPlayedAt: Value(DateTime.now()),
            playCount: Value((existing?.playCount ?? 0) + 1),
            positionMs: Value(existing?.positionMs ?? 0),
            completed: Value(existing?.completed ?? false),
            audioTrack: Value(existing?.audioTrack),
            subtitleTrack: Value(existing?.subtitleTrack),
            speed: Value(existing?.speed),
          ),
        );
  }

  /// Salva a posição. Se passou de 95 %, marca como concluído e zera a
  /// posição (próxima reprodução começa do início).
  Future<void> savePosition(
    int videoId, {
    required Duration position,
    required Duration duration,
  }) async {
    final completed = duration > Duration.zero &&
        position.inMilliseconds / duration.inMilliseconds >= completedThreshold;
    await _upsert(
      videoId,
      PlaybackStateCompanion(
        positionMs: Value(completed ? 0 : position.inMilliseconds),
        completed: Value(completed),
        lastPlayedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setCompleted(int videoId, bool completed) => _upsert(
        videoId,
        PlaybackStateCompanion(
          completed: Value(completed),
          positionMs: const Value(0),
        ),
      );

  Future<void> savePreferences(
    int videoId, {
    String? audioTrack,
    String? subtitleTrack,
    double? speed,
  }) =>
      _upsert(
        videoId,
        PlaybackStateCompanion(
          audioTrack:
              audioTrack == null ? const Value.absent() : Value(audioTrack),
          subtitleTrack: subtitleTrack == null
              ? const Value.absent()
              : Value(subtitleTrack),
          speed: speed == null ? const Value.absent() : Value(speed),
        ),
      );

  /// Limpa o histórico (data da última reprodução e posição), mantendo
  /// o status de "assistido".
  Future<void> clearHistory() => _db.update(_db.playbackState).write(
        const PlaybackStateCompanion(
          lastPlayedAt: Value(null),
          positionMs: Value(0),
        ),
      );

  Future<void> removeFromHistory(int videoId) =>
      (_db.update(_db.playbackState)..where((p) => p.videoId.equals(videoId)))
          .write(const PlaybackStateCompanion(lastPlayedAt: Value(null)));

  Future<void> _upsert(int videoId, PlaybackStateCompanion data) async {
    final updated = await (_db.update(_db.playbackState)
          ..where((p) => p.videoId.equals(videoId)))
        .write(data);
    if (updated == 0) {
      await _db
          .into(_db.playbackState)
          .insert(data.copyWith(videoId: Value(videoId)));
    }
  }
}
