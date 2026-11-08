import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/core/utils/formatters.dart';
import 'package:localtube/core/utils/video_extensions.dart';
import 'package:localtube/features/home/domain/home_filter.dart';
import 'package:localtube/features/library/domain/history_groups.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 11, 8, 15);

  group('applyHomeFilter', () {
    final watching = fakeVideo(
        id: 1, title: 'meio', positionMs: 1000, lastPlayedAt: now);
    final done = fakeVideo(id: 2, title: 'fim', completed: true);
    final fresh = fakeVideo(
      id: 3,
      title: 'novo',
      folderId: 2,
      container: 'mkv',
      addedAt: now.subtract(const Duration(days: 1)),
      modifiedAt: now.subtract(const Duration(days: 1)),
    );
    final old = fakeVideo(
      id: 4,
      title: 'antigo',
      addedAt: now.subtract(const Duration(days: 400)),
      modifiedAt: now.subtract(const Duration(days: 400)),
    );
    final all = [watching, done, fresh, old];

    List<int> ids(HomeFilter f) =>
        applyHomeFilter(all, f, now: now).map((v) => v.id).toList();

    test('Todos', () => expect(ids(const AllFilter()), [1, 2, 3, 4]));
    test('Continuar assistindo',
        () => expect(ids(const ContinueWatchingFilter()), [1]));
    test('Não assistidos', () => expect(ids(const UnwatchedFilter()), [3, 4]));
    test('Pasta', () => expect(ids(const FolderFilter(2)), [3]));
    test('Formato', () => expect(ids(const FormatFilter('mkv')), [3]));
    test('Recentes exclui antigos',
        () => expect(ids(const RecentFilter()), isNot(contains(4))));
  });

  group('groupHistory', () {
    test('agrupa em Hoje/Ontem/Esta semana/Mais antigos', () {
      final items = [
        fakeVideo(id: 1, lastPlayedAt: now.subtract(const Duration(hours: 1))),
        fakeVideo(id: 2, lastPlayedAt: now.subtract(const Duration(days: 1))),
        fakeVideo(id: 3, lastPlayedAt: now.subtract(const Duration(days: 4))),
        fakeVideo(id: 4, lastPlayedAt: now.subtract(const Duration(days: 30))),
      ];
      final g = groupHistory(items, now: now);
      expect(g.keys, HistoryGroup.values);
      expect(g[HistoryGroup.today]!.single.id, 1);
      expect(g[HistoryGroup.yesterday]!.single.id, 2);
      expect(g[HistoryGroup.thisWeek]!.single.id, 3);
      expect(g[HistoryGroup.older]!.single.id, 4);
    });
  });

  group('Fmt', () {
    test('tamanho de arquivo em pt-BR', () {
      expect(Fmt.fileSize(1288490189), '1,2 GB');
      expect(Fmt.fileSize(850 * 1024 * 1024), '850 MB');
      expect(Fmt.fileSize(500), '500 B');
    });

    test('duração', () {
      expect(Fmt.duration(const Duration(minutes: 4, seconds: 5)), '4:05');
      expect(Fmt.duration(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '1:02:03');
    });

    test('resolução (inclui vídeos verticais)', () {
      expect(Fmt.resolution(1920, 1080), '1080p');
      expect(Fmt.resolution(1080, 1920), '1080p');
      expect(Fmt.resolution(3840, 2160), '2160p (4K)');
      expect(Fmt.resolution(1280, 534), '480p');
      expect(Fmt.resolution(null, null), isNull);
    });

    test('tempo relativo', () {
      expect(Fmt.relative(now.subtract(const Duration(days: 3)), now: now),
          'há 3 dias');
      expect(Fmt.relative(now.subtract(const Duration(hours: 1)), now: now),
          'há 1 hora');
      expect(Fmt.relative(now, now: now), 'agora mesmo');
    });
  });

  group('extensões', () {
    test('reconhece vídeos sem diferenciar caixa', () {
      expect(isVideoFile('/a/B.MKV'), isTrue);
      expect(isVideoFile('/a/b.srt'), isFalse);
    });

    test('título a partir do nome do arquivo', () {
      expect(titleFromFileName('Minha_viagem.2024.mp4'), 'Minha viagem 2024');
    });
  });
}
