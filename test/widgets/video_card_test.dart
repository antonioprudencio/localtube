import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/core/widgets/duration_badge.dart';
import 'package:localtube/core/widgets/progress_overlay.dart';
import 'package:localtube/core/widgets/video_card.dart';
import 'package:localtube/core/widgets/video_thumbnail.dart';

import '../helpers.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, Widget card) async {
    await tester.pumpWidget(testApp(
      Scaffold(body: Center(child: SizedBox(width: 360, child: card))),
    ));
    await tester.pump();
  }

  testWidgets('mostra título, selo de duração e metadados', (tester) async {
    var tapped = 0;
    await pumpCard(
      tester,
      VideoCard(item: fakeVideo(), onTap: () => tapped++),
    );

    expect(find.text('Meu vídeo de férias'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Viagens • 1,2 GB • 1080p • há 3 dias'), findsOneWidget);
    // "Avatar do canal" com a inicial da pasta.
    expect(find.text('V'), findsOneWidget);

    await tester.tap(find.text('Meu vídeo de férias'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tapped, 1);
  });

  testWidgets('barra de progresso aparece só quando parcialmente assistido',
      (tester) async {
    await pumpCard(tester, VideoCard(item: fakeVideo(), onTap: () {}));
    expect(
      tester.widget<ProgressOverlay>(find.byType(ProgressOverlay)).progress,
      isNull,
    );

    await pumpCard(
      tester,
      VideoCard(item: fakeVideo(positionMs: 300000), onTap: () {}),
    );
    expect(
      tester.widget<ProgressOverlay>(find.byType(ProgressOverlay)).progress,
      closeTo(0.5, 0.001),
    );
  });

  testWidgets('shimmer enquanto a miniatura não foi gerada', (tester) async {
    await pumpCard(
      tester,
      VideoCard(item: fakeVideo(durationMs: null), onTap: () {}),
    );
    expect(find.byType(Shimmer), findsOneWidget);
    // Sem duração ainda, sem selo.
    expect(find.descendant(of: find.byType(DurationBadge), matching: find.byType(Text)),
        findsNothing);
  });

  testWidgets('vídeo indisponível mostra o selo "Indisponível"', (tester) async {
    await pumpCard(
      tester,
      VideoCard(item: fakeVideo(isAvailable: false), onTap: () {}),
    );
    expect(find.text('Indisponível'), findsOneWidget);
  });

  testWidgets('menu ⋮ abre as ações do vídeo', (tester) async {
    await pumpCard(tester, VideoCard(item: fakeVideo(), onTap: () {}));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Salvar na playlist'), findsOneWidget);
    expect(find.text('Favoritar'), findsOneWidget);
    expect(find.text('Marcar como assistido'), findsOneWidget);
    expect(find.text('Informações do arquivo'), findsOneWidget);
    expect(find.text('Remover da biblioteca'), findsOneWidget);
  });
}
