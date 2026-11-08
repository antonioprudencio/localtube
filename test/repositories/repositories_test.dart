import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/core/db/database.dart';
import 'package:localtube/features/folders/data/folder_repository.dart';
import 'package:localtube/features/folders/domain/library_diff.dart';
import 'package:localtube/features/library/data/video_repository.dart';
import 'package:localtube/features/player/data/playback_repository.dart';
import 'package:localtube/features/playlists/data/playlist_repository.dart';
import 'package:localtube/features/search/data/search_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late FolderRepository folders;
  late VideoRepository videos;
  late PlaybackRepository playback;
  late PlaylistRepository playlists;
  late SearchRepository search;
  final t0 = DateTime(2026, 3, 1);

  setUp(() {
    db = testDatabase();
    folders = FolderRepository(db);
    videos = VideoRepository(db);
    playback = PlaybackRepository(db);
    playlists = PlaylistRepository(db);
    search = SearchRepository(db);
  });

  tearDown(() => db.close());

  /// Cria uma pasta com os arquivos informados e retorna o id da pasta.
  Future<int> seed(String folderPath, List<String> names) async {
    final f = await folders.addFolder(folderPath);
    await folders.applyDiff(
      f.id,
      LibraryDiff(added: [
        for (final (i, n) in names.indexed)
          ScannedFile(
            path: '$folderPath/$n',
            sizeBytes: 1000 * (i + 1),
            modifiedAt: t0.add(Duration(days: i)),
          ),
      ]),
    );
    return f.id;
  }

  group('FolderRepository', () {
    test('addFolder normaliza o caminho e não duplica', () async {
      final a = await folders.addFolder('/videos/Filmes/');
      final b = await folders.addFolder('/videos/Filmes');
      expect(a.id, b.id);
      expect(a.name, 'Filmes');
      expect(await folders.getFolders(), hasLength(1));
    });

    test('applyDiff insere com título amigável e contêiner', () async {
      final id = await seed('/v', ['Minha_viagem.2024.mkv']);
      final list = await videos.watchAll(folderId: id).first;
      expect(list.single.title, 'Minha viagem 2024');
      expect(list.single.video.container, 'mkv');
      expect(list.single.video.durationMs, isNull); // aguardando extração
    });

    test('resumo da pasta conta vídeos e soma tamanhos disponíveis', () async {
      final id = await seed('/v', ['a.mp4', 'b.mp4']);
      final s = (await folders.watchSummaries().first).single;
      expect(s.videoCount, 2);
      expect(s.totalBytes, 3000);

      await folders.markFolderUnavailable(id);
      final s2 = (await folders.watchSummaries().first).single;
      expect(s2.videoCount, 0);
    });

    test('marcar indisponível preserva histórico', () async {
      final id = await seed('/usb', ['a.mp4']);
      final v = (await videos.watchAll().first).single;
      await playback.markStarted(v.id);
      await folders.markFolderUnavailable(id);

      expect(await videos.watchAll().first, isEmpty);
      final history = await videos.watchHistory().first;
      expect(history.single.video.isAvailable, isFalse);
    });

    test('remover pasta apaga vídeos em cascata', () async {
      final id = await seed('/v', ['a.mp4']);
      await folders.removeFolder(id);
      expect(await videos.watchAll().first, isEmpty);
    });
  });

  group('VideoRepository', () {
    test('ordena por data de modificação (mais recente primeiro)', () async {
      await seed('/v', ['velho.mp4', 'medio.mp4', 'novo.mp4']);
      final list = await videos.watchAll().first;
      expect(list.map((v) => v.title), ['novo', 'medio', 'velho']);
    });

    test('busca por título, nome do arquivo e pasta, sem diferenciar caixa',
        () async {
      await seed('/v/Shows', ['Concerto Rock.mp4', 'Jazz.mkv']);
      await seed('/v/Aulas', ['Matematica.mp4']);

      expect((await videos.search('rock')).single.title, 'Concerto Rock');
      expect((await videos.search('JAZZ.MKV')).single.title, 'Jazz');
      expect(await videos.search('shows'), hasLength(2));
      expect(await videos.search(''), isEmpty);
      expect(await videos.search('100%'), isEmpty);
    });

    test('favoritos e assistir mais tarde', () async {
      await seed('/v', ['a.mp4', 'b.mp4']);
      final a = (await videos.search('a')).first;
      await videos.setFavorite(a.id, true);
      await videos.setWatchLater(a.id, true);
      expect((await videos.watchFavorites().first).single.id, a.id);
      expect((await videos.watchWatchLater().first).single.id, a.id);
    });

    test('remover da biblioteca ignora o caminho em scans futuros', () async {
      final id = await seed('/v', ['a.mp4']);
      final a = (await videos.watchAll().first).single;
      await videos.removeFromLibrary(a.id);

      expect(await videos.watchAll().first, isEmpty);
      final diff = computeLibraryDiff(
        scanned: [ScannedFile(path: '/v/a.mp4', sizeBytes: 1000, modifiedAt: t0)],
        indexed: await folders.indexedFiles(id),
        ignored: await folders.ignoredPaths(),
      );
      expect(diff.added, isEmpty);
    });

    test('fila de extração: pendentes até salvar metadados', () async {
      await seed('/v', ['a.mp4', 'b.mp4']);
      final pending = await videos.pendingProbe();
      expect(pending, hasLength(2));

      await videos.saveMetadata(
        pending.first.id,
        const VideoMetadata(
            durationMs: 5000, width: 1280, height: 720, videoCodec: 'h264'),
      );
      expect(await videos.pendingProbe(), hasLength(1));

      final item = await videos.getById(pending.first.id);
      expect(item!.duration, const Duration(seconds: 5));
      expect(item.video.width, 1280);

      await videos.resetThumbnails();
      expect(await videos.pendingProbe(), hasLength(2));
    });

    test('contêineres distintos para os chips de formato', () async {
      await seed('/v', ['a.mp4', 'b.mkv', 'c.mp4']);
      expect(await videos.watchContainers().first, ['mkv', 'mp4']);
    });
  });

  group('PlaybackRepository', () {
    late int videoId;

    setUp(() async {
      await seed('/v', ['a.mp4']);
      videoId = (await videos.watchAll().first).single.id;
    });

    test('salva posição e aparece em "Continuar assistindo"', () async {
      await playback.markStarted(videoId);
      await playback.savePosition(videoId,
          position: const Duration(minutes: 3),
          duration: const Duration(minutes: 10));

      final s = await playback.get(videoId);
      expect(s!.positionMs, 180000);
      expect(s.completed, isFalse);
      expect(s.playCount, 1);
      expect((await videos.watchContinueWatching().first).single.id, videoId);
    });

    test('acima de 95 % marca como concluído e zera a posição', () async {
      await playback.savePosition(videoId,
          position: const Duration(seconds: 96),
          duration: const Duration(seconds: 100));
      final s = await playback.get(videoId);
      expect(s!.completed, isTrue);
      expect(s.positionMs, 0);
      expect(await videos.watchContinueWatching().first, isEmpty);
    });

    test('markStarted incrementa contagem e preserva posição', () async {
      await playback.savePosition(videoId,
          position: const Duration(seconds: 30),
          duration: const Duration(seconds: 100));
      await playback.markStarted(videoId);
      await playback.markStarted(videoId);
      final s = await playback.get(videoId);
      expect(s!.playCount, 2);
      expect(s.positionMs, 30000);
    });

    test('preferências de faixa e velocidade', () async {
      await playback.savePreferences(videoId,
          audioTrack: '2', subtitleTrack: '3', speed: 1.5);
      final s = await playback.get(videoId);
      expect(s!.audioTrack, '2');
      expect(s.subtitleTrack, '3');
      expect(s.speed, 1.5);
    });

    test('limpar histórico mantém status de assistido', () async {
      await playback.markStarted(videoId);
      await playback.setCompleted(videoId, true);
      await playback.clearHistory();
      expect(await videos.watchHistory().first, isEmpty);
      expect((await playback.get(videoId))!.completed, isTrue);
    });
  });

  group('PlaylistRepository', () {
    test('criar, adicionar, reordenar, remover e excluir', () async {
      await seed('/v', ['a.mp4', 'b.mp4', 'c.mp4']);
      final all = await videos.watchAll().first; // c, b, a
      final p = await playlists.create('  Favoritas  ');
      expect(p.name, 'Favoritas');

      for (final v in all.reversed) {
        await playlists.addVideo(p.id, v.id); // a, b, c
      }
      await playlists.addVideo(p.id, all.first.id); // duplicado: ignorado

      var items = await playlists.watchItems(p.id).first;
      expect(items.map((v) => v.title), ['a', 'b', 'c']);

      await playlists.reorder(p.id, [items[2].id, items[0].id, items[1].id]);
      items = await playlists.watchItems(p.id).first;
      expect(items.map((v) => v.title), ['c', 'a', 'b']);

      await playlists.removeVideo(p.id, items.first.id);
      items = await playlists.watchItems(p.id).first;
      expect(items.map((v) => v.title), ['a', 'b']);

      final summary = (await playlists.watchPlaylists().first).single;
      expect(summary.itemCount, 2);
      expect(await playlists.playlistsContaining(items.first.id), {p.id});

      await playlists.rename(p.id, 'Melhores');
      expect((await playlists.getPlaylists()).single.name, 'Melhores');

      await playlists.delete(p.id);
      expect(await playlists.getPlaylists(), isEmpty);
    });
  });

  group('SearchRepository', () {
    test('histórico sem duplicados, mais recente primeiro', () async {
      await search.add('rock');
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await search.add('jazz');
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await search.add('rock');
      await search.add('   ');
      expect(await search.watchHistory().first, ['rock', 'jazz']);

      await search.remove('rock');
      expect(await search.watchHistory().first, ['jazz']);
      await search.clear();
      expect(await search.watchHistory().first, isEmpty);
    });
  });
}
