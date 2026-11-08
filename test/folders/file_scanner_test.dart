import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localtube/features/folders/data/file_scanner.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('localtube_scan_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  void file(String rel, {int size = 10}) {
    final f = File(p.join(root.path, rel));
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(List.filled(size, 0));
  }

  List<String> relPaths(ScanResult r) =>
      r.files.map((f) => p.relative(f.path, from: root.path)).toList()..sort();

  test('encontra vídeos recursivamente e filtra por extensão', () {
    file('a.mp4');
    file('B.MKV');
    file('sub/c.webm');
    file('sub/deeper/d.m2ts');
    file('notas.txt');
    file('capa.jpg');
    file('legenda.srt');

    final r = scanFolderSync(ScanOptions(root: root.path));
    expect(r.rootExists, isTrue);
    expect(relPaths(r), [
      'B.MKV',
      'a.mp4',
      p.join('sub', 'c.webm'),
      p.join('sub', 'deeper', 'd.m2ts'),
    ]);
  });

  test('respeita a lista de extensões configurada', () {
    file('a.mp4');
    file('b.mkv');
    final r = scanFolderSync(ScanOptions(root: root.path, extensions: const ['mkv']));
    expect(relPaths(r), ['b.mkv']);
  });

  test('ignora arquivos menores que o tamanho mínimo', () {
    file('pequeno.mp4', size: 5);
    file('grande.mp4', size: 50);
    final r = scanFolderSync(ScanOptions(root: root.path, minSizeBytes: 20));
    expect(relPaths(r), ['grande.mp4']);
  });

  test('ignora pastas com .nomedia, Android/data e pastas ocultas', () {
    file('ok.mp4');
    file('privado/x.mp4');
    file('privado/.nomedia');
    file('Android/data/com.app/cache.mp4');
    file('.oculta/y.mp4');
    final r = scanFolderSync(ScanOptions(root: root.path));
    expect(relPaths(r), ['ok.mp4']);
  });

  test('pasta inexistente retorna rootExists = false (sem apagar nada)', () {
    final r = scanFolderSync(ScanOptions(root: p.join(root.path, 'nao_existe')));
    expect(r.rootExists, isFalse);
    expect(r.files, isEmpty);
  });

  test('scanFolder roda em Isolate e retorna o mesmo resultado', () async {
    file('a.mp4', size: 123);
    final r = await scanFolder(ScanOptions(root: root.path));
    expect(r.files.single.sizeBytes, 123);
  });
}
