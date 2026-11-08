import 'package:drift/drift.dart';

/// Pastas monitoradas pelo usuário.
@DataClassName('FolderRow')
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  TextColumn get name => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastScanAt => dateTime().nullable()();
}

/// Vídeos indexados.
///
/// `durationMs == null` significa "metadados ainda não extraídos"; a fila de
/// extração processa esses registros. `durationMs == 0` indica que o arquivo
/// não pôde ser lido pelo player.
@DataClassName('VideoRow')
class Videos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().references(Folders, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text().unique()();
  TextColumn get fileName => text()();
  TextColumn get title => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get videoCodec => text().nullable()();
  TextColumn get audioCodec => text().nullable()();
  TextColumn get container => text()();
  DateTimeColumn get modifiedAt => dateTime()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get thumbPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get watchLater => boolean().withDefault(const Constant(false))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
}

/// Progresso/estado de reprodução por vídeo (também serve de histórico).
@DataClassName('PlaybackStateRow')
class PlaybackState extends Table {
  @override
  String get tableName => 'playback_state';

  IntColumn get videoId =>
      integer().references(Videos, #id, onDelete: KeyAction.cascade)();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  TextColumn get audioTrack => text().nullable()();
  TextColumn get subtitleTrack => text().nullable()();
  RealColumn get speed => real().nullable()();

  @override
  Set<Column> get primaryKey => {videoId};
}

@DataClassName('PlaylistRow')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PlaylistItemRow')
class PlaylistItems extends Table {
  @override
  String get tableName => 'playlist_items';

  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get videoId =>
      integer().references(Videos, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, videoId};
}

@DataClassName('SearchHistoryRow')
class SearchHistory extends Table {
  @override
  String get tableName => 'search_history';

  TextColumn get term => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {term};
}

/// Caminhos que o usuário removeu da biblioteca: o scanner não os re-adiciona.
@DataClassName('IgnoredPathRow')
class IgnoredPaths extends Table {
  @override
  String get tableName => 'ignored_paths';

  TextColumn get path => text()();

  @override
  Set<Column> get primaryKey => {path};
}
