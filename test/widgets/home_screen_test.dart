import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/core/db/database.dart';
import 'package:localtube/core/models/video_item.dart';
import 'package:localtube/core/widgets/video_card.dart';
import 'package:localtube/features/home/presentation/home_providers.dart';
import 'package:localtube/features/home/presentation/home_screen.dart';

import '../helpers.dart';

void main() {
  FolderRow folder(int id, String name) => FolderRow(
        id: id,
        path: '/videos/$name',
        name: name,
        addedAt: DateTime(2026),
        lastScanAt: DateTime(2026),
      );

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<FolderRow> folders,
    List<VideoItem> videos = const [],
    List<VideoItem> continueWatching = const [],
    Size size = const Size(400, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp(
      const HomeScreen(),
      overrides: [
        foldersProvider.overrideWith((ref) => Stream.value(folders)),
        allVideosProvider.overrideWith((ref) => Stream.value(videos)),
        containersProvider.overrideWith((ref) =>
            Stream.value(videos.map((v) => v.video.container).toSet().toList())),
        continueWatchingProvider
            .overrideWith((ref) => Stream.value(continueWatching)),
      ],
    ));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('primeira execução mostra a tela de boas-vindas', (tester) async {
    await pumpHome(tester, folders: const []);
    expect(find.text('Bem-vindo ao LocalTube'), findsOneWidget);
    expect(find.text('Adicionar pasta de vídeos'), findsOneWidget);
  });

  testWidgets('mostra chips de filtro e a grade de vídeos', (tester) async {
    final videos = [
      fakeVideo(id: 1, title: 'Primeiro', container: 'mkv'),
      fakeVideo(id: 2, title: 'Segundo'),
    ];
    await pumpHome(tester,
        folders: [folder(1, 'Viagens')],
        videos: videos,
        size: const Size(1400, 900));

    for (final chip in ['Todos', 'Continuar assistindo', 'Recentes']) {
      expect(find.widgetWithText(ChoiceChip, chip), findsOneWidget);
    }
    expect(find.widgetWithText(ChoiceChip, 'Viagens'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'MKV'), findsOneWidget);
    expect(find.byType(VideoCard), findsNWidgets(2));
  });

  testWidgets('filtro por formato reduz a grade', (tester) async {
    final videos = [
      fakeVideo(id: 1, title: 'Primeiro', container: 'mkv'),
      fakeVideo(id: 2, title: 'Segundo'),
    ];
    await pumpHome(tester,
        folders: [folder(1, 'Viagens')],
        videos: videos,
        size: const Size(1400, 900));

    await tester.tap(find.widgetWithText(ChoiceChip, 'MKV'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(VideoCard), findsOneWidget);
    expect(find.text('Primeiro'), findsOneWidget);
    expect(find.text('Segundo'), findsNothing);
  });

  testWidgets('seção "Continuar assistindo" aparece quando há progresso',
      (tester) async {
    final watching = fakeVideo(id: 9, title: 'Pela metade', positionMs: 1000);
    await pumpHome(
      tester,
      folders: [folder(1, 'Viagens')],
      videos: [watching],
      continueWatching: [watching],
    );
    // Título da seção + chip com o mesmo texto.
    expect(find.text('Continuar assistindo'), findsNWidgets(2));
    expect(find.byType(ContinueWatchingRow), findsOneWidget);
  });

  testWidgets('grade usa várias colunas em janelas largas', (tester) async {
    final videos = [for (var i = 1; i <= 8; i++) fakeVideo(id: i, title: 'V$i')];
    await pumpHome(
      tester,
      folders: [folder(1, 'Viagens')],
      videos: videos,
      size: const Size(1400, 900),
    );
    final first = tester.getTopLeft(find.text('V1'));
    final second = tester.getTopLeft(find.text('V2'));
    expect(first.dy, second.dy); // mesma linha
  });
}
