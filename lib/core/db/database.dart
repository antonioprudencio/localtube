import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.drift.dart';

@DriftDatabase(
  tables: [
    Folders,
    Videos,
    PlaybackState,
    Playlists,
    PlaylistItems,
    SearchHistory,
    IgnoredPaths,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Banco em memória, usado nos testes.
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  /// Abre (ou cria) `localtube.db` na pasta de suporte do app.
  static Future<AppDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, 'localtube.db'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_videos_folder ON videos(folder_id)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_playback_last ON playback_state(last_played_at)');
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
