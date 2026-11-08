import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/core/db/database.dart';
import 'package:localtube/core/providers.dart';
import 'package:localtube/features/folders/domain/library_indexer.dart';
import 'package:localtube/features/library/data/video_repository.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

/// Extrator fake: "lê" a duração a partir do tamanho do arquivo.
class FakeProber implements VideoProber {
  final probed = <String>[];

  @override
  Future<VideoMetadata> probe({required int videoId, required String path}) async {
    probed.add(path);
    if (path.endsWith('corrompido.mp4')) return const VideoMetadata(durationMs: 0);
    return VideoMetadata(
      durationMs: File(path).lengthSync() * 1000,
      width: 1920,
      height: 1080,
      videoCodec: 'h264',
      audioCodec: 'aac',
    );
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory root;
  late AppDatabase db;
  late ProviderContainer container;
  late FakeProber prober;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('localtube_idx_');
    db = testDatabase();
    prober = FakeProber();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
      proberFactoryProvider.overrideWithValue(() async => prober),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  void file(String rel, {int size = 10}) {
    final f = File(p.join(root.path, rel));
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(List.filled(size, 0));
  }

  LibraryIndexer indexer() => container.read(libraryIndexerProvider.notifier);
  VideoRepository videos() => container.read(videoRepositoryProvider);

  test('adicionar pasta indexa vídeos e extrai metadados', () async {
    file('a.mp4', size: 5);
    file('sub/b.mkv', size: 7);
    file('leia.txt');

    await indexer().addFolder(root.path);
    await indexer().processQueue();

    final list = await videos().watchAll().first;
    expect(list, hasLength(2));
    expect(list.every((v) => v.video.durationMs != null), isTrue);
    expect(prober.probed, hasLength(2));
    final a = list.firstWhere((v) => v.video.fileName == 'a.mp4');
    expect(a.duration, const Duration(seconds: 5));
    expect(container.read(libraryIndexerProvider).busy, isFalse);
  });

  test('reescanear detecta novos, alterados e removidos', () async {
    file('a.mp4', size: 5);
    file('b.mp4', size: 5);
    final folder = await indexer().addFolder(root.path);
    await indexer().processQueue();

    file('c.mp4', size: 3); // novo
    file('a.mp4', size: 9); // alterado
    File(p.join(root.path, 'b.mp4')).deleteSync(); // removido

    await indexer().rescanFolder(folder);
    await indexer().processQueue();

    final list = await videos().watchAll().first;
    expect(list.map((v) => v.video.fileName).toSet(), {'a.mp4', 'c.mp4'});
    final a = list.firstWhere((v) => v.video.fileName == 'a.mp4');
    expect(a.duration, const Duration(seconds: 9)); // metadados re-extraídos
  });

  test('pasta desconectada marca vídeos indisponíveis e depois restaura',
      () async {
    file('a.mp4', size: 5);
    final folder = await indexer().addFolder(root.path);
    await indexer().processQueue();
    final id = (await videos().watchAll().first).single.id;

    final moved = Directory('${root.path}_offline');
    root.renameSync(moved.path);
    await indexer().rescanFolder(folder);
    expect(await videos().watchAll().first, isEmpty);
    expect((await videos().getById(id))!.video.isAvailable, isFalse);

    moved.renameSync(root.path);
    await indexer().rescanFolder(folder);
    expect((await videos().getById(id))!.video.isAvailable, isTrue);
  });

  test('arquivo ilegível recebe duração 0 e sai da fila', () async {
    file('corrompido.mp4');
    await indexer().addFolder(root.path);
    await indexer().processQueue();
    expect(await videos().pendingProbe(), isEmpty);
    final v = (await videos().watchAll().first).single;
    expect(v.duration, isNull);
  });
}
