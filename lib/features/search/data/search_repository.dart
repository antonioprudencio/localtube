import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';

part 'search_repository.g.dart';

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) =>
    SearchRepository(ref.watch(appDatabaseProvider));

/// Histórico de buscas (termos mais recentes primeiro).
class SearchRepository {
  SearchRepository(this._db);

  final AppDatabase _db;
  static const _maxEntries = 30;

  Stream<List<String>> watchHistory() => (_db.select(_db.searchHistory)
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
        ..limit(_maxEntries))
      .watch()
      .map((rows) => rows.map((r) => r.term).toList());

  Future<void> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    await _db.into(_db.searchHistory).insertOnConflictUpdate(
          SearchHistoryCompanion.insert(term: t, createdAt: Value(DateTime.now())),
        );
  }

  Future<void> remove(String term) =>
      (_db.delete(_db.searchHistory)..where((s) => s.term.equals(term))).go();

  Future<void> clear() => _db.delete(_db.searchHistory).go();
}
