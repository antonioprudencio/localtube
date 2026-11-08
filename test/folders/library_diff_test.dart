import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/features/folders/domain/library_diff.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 12);

  ScannedFile scanned(String path, {int size = 100, DateTime? modified}) =>
      ScannedFile(path: path, sizeBytes: size, modifiedAt: modified ?? t0);

  IndexedFile indexed(int id, String path,
          {int size = 100, DateTime? modified, bool available = true}) =>
      IndexedFile(
        id: id,
        path: path,
        sizeBytes: size,
        modifiedAt: modified ?? t0,
        isAvailable: available,
      );

  group('computeLibraryDiff', () {
    test('banco vazio: tudo é novo', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4'), scanned('/b.mkv')],
        indexed: const [],
      );
      expect(diff.added.map((f) => f.path), ['/a.mp4', '/b.mkv']);
      expect(diff.changed, isEmpty);
      expect(diff.missing, isEmpty);
      expect(diff.restored, isEmpty);
    });

    test('arquivos iguais não geram mudanças', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4')],
        indexed: [indexed(1, '/a.mp4')],
      );
      expect(diff.isEmpty, isTrue);
    });

    test('mudança de tamanho é detectada', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4', size: 200)],
        indexed: [indexed(1, '/a.mp4', size: 100)],
      );
      expect(diff.changed.single.id, 1);
      expect(diff.changed.single.file.sizeBytes, 200);
    });

    test('mudança de data acima de 2 s é detectada; até 2 s é tolerada', () {
      final tolerated = computeLibraryDiff(
        scanned: [scanned('/a.mp4', modified: t0.add(const Duration(seconds: 2)))],
        indexed: [indexed(1, '/a.mp4')],
      );
      expect(tolerated.isEmpty, isTrue);

      final changed = computeLibraryDiff(
        scanned: [scanned('/a.mp4', modified: t0.add(const Duration(minutes: 1)))],
        indexed: [indexed(1, '/a.mp4')],
      );
      expect(changed.changed.single.id, 1);
    });

    test('arquivo sumido é marcado como indisponível (não apagado)', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4')],
        indexed: [indexed(1, '/a.mp4'), indexed(2, '/b.mp4')],
      );
      expect(diff.missing, [2]);
      expect(diff.added, isEmpty);
    });

    test('já indisponível e ainda sumido não entra de novo em missing', () {
      final diff = computeLibraryDiff(
        scanned: const [],
        indexed: [indexed(2, '/b.mp4', available: false)],
      );
      expect(diff.missing, isEmpty);
    });

    test('arquivo que reaparece igual é restaurado', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/b.mp4')],
        indexed: [indexed(2, '/b.mp4', available: false)],
      );
      expect(diff.restored, [2]);
    });

    test('caminhos ignorados (removidos pelo usuário) não são re-adicionados', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4'), scanned('/b.mp4')],
        indexed: const [],
        ignored: {'/b.mp4'},
      );
      expect(diff.added.map((f) => f.path), ['/a.mp4']);
    });

    test('caminhos duplicados no scan são considerados uma vez', () {
      final diff = computeLibraryDiff(
        scanned: [scanned('/a.mp4'), scanned('/a.mp4')],
        indexed: const [],
      );
      expect(diff.added, hasLength(1));
    });
  });
}
