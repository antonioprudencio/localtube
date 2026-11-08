import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/platform/android_permissions.dart';
import '../../library/data/video_repository.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/file_scanner.dart';
import '../data/folder_repository.dart';
import '../data/media_probe_service.dart';
import 'library_diff.dart';

part 'library_indexer.g.dart';

/// Interface mínima do extrator de metadados (permite substituir nos testes).
abstract interface class VideoProber {
  Future<VideoMetadata> probe({required int videoId, required String path});
  Future<void> dispose();
}

class _MediaKitProber implements VideoProber {
  _MediaKitProber(this._probe);
  final MediaProbe _probe;

  @override
  Future<VideoMetadata> probe({required int videoId, required String path}) =>
      _probe.probe(videoId: videoId, path: path);

  @override
  Future<void> dispose() => _probe.dispose();
}

/// Fábrica de extratores. Nos testes é sobrescrita por um fake.
@Riverpod(keepAlive: true)
Future<VideoProber> Function() proberFactory(Ref ref) => () async {
      final dir = await thumbnailsDirectory();
      return _MediaKitProber(MediaProbe(thumbsDir: dir.path));
    };

Future<Directory> thumbnailsDirectory() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(p.join(base.path, 'thumbs'));
  await dir.create(recursive: true);
  return dir;
}

@immutable
class IndexerState {
  const IndexerState({this.scanning = false, this.pendingProbe = 0});

  final bool scanning;

  /// Vídeos aguardando extração de metadados/miniatura.
  final int pendingProbe;

  bool get busy => scanning || pendingProbe > 0;

  IndexerState copyWith({bool? scanning, int? pendingProbe}) => IndexerState(
        scanning: scanning ?? this.scanning,
        pendingProbe: pendingProbe ?? this.pendingProbe,
      );
}

/// Coordena scan das pastas, sincronização com o banco e fila de metadados.
@Riverpod(keepAlive: true)
class LibraryIndexer extends _$LibraryIndexer {
  /// No Android a decodificação (ex.: AV1 por software) é pesada: 1 extrator.
  static int get _concurrency => Platform.isAndroid ? 1 : 2;

  /// Enquanto um vídeo toca, a fila de extração fica em pausa.
  bool _playbackActive = false;

  void setPlaybackActive(bool active) => _playbackActive = active;

  Future<void> _waitWhilePlaying() async {
    while (_playbackActive && ref.mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  final _probers = <VideoProber>[];
  final _inFlight = <int>{};
  final _watchers = <int, StreamSubscription<FileSystemEvent>>{};
  final _debouncers = <int, Timer>{};
  Future<void>? _queue;
  bool _rerun = false;
  int _activeScans = 0;

  FolderRepository get _folders => ref.read(folderRepositoryProvider);
  VideoRepository get _videos => ref.read(videoRepositoryProvider);

  @override
  IndexerState build() {
    ref.onDispose(() {
      for (final w in _watchers.values) {
        w.cancel();
      }
      for (final d in _debouncers.values) {
        d.cancel();
      }
      for (final pr in _probers) {
        pr.dispose();
      }
    });
    return const IndexerState();
  }

  /// Chamado na abertura do app: detecta mudanças e liga a vigilância.
  Future<void> startup() async {
    // Sem permissão, o Android esconde os vídeos ao listar as pastas: um scan
    // agora marcaria toda a biblioteca como indisponível.
    if (!await AndroidPermissions.hasVideoAccess()) {
      debugPrint('[LibraryIndexer] sem permissão de vídeos; scan adiado');
      return;
    }
    await rescanAll();
    if (Platform.isWindows) {
      for (final f in await _folders.getFolders()) {
        _watch(f);
      }
    }
  }

  Future<FolderRow> addFolder(String path) async {
    final folder = await _folders.addFolder(path);
    await rescanFolder(folder);
    if (Platform.isWindows) _watch(folder);
    return folder;
  }

  Future<void> removeFolder(int id) async {
    await _watchers.remove(id)?.cancel();
    _debouncers.remove(id)?.cancel();
    await _folders.removeFolder(id);
  }

  Future<void> rescanAll() async {
    final folders = await _folders.getFolders();
    for (final f in folders) {
      await rescanFolder(f);
    }
  }

  Future<void> rescanFolder(FolderRow folder) async {
    _setScanning(1);
    try {
      final settings = ref.read(settingsProvider);
      final result = await scanFolder(ScanOptions(
        root: folder.path,
        extensions: settings.extensions,
        minSizeBytes: settings.minSizeBytes,
      ));
      if (!ref.mounted) return;
      if (!result.rootExists) {
        // Unidade desconectada / pasta inacessível: preserva tudo.
        await _folders.markFolderUnavailable(folder.id);
        return;
      }
      final diff = computeLibraryDiff(
        scanned: result.files,
        indexed: await _folders.indexedFiles(folder.id),
        ignored: await _folders.ignoredPaths(),
      );
      await _folders.applyDiff(folder.id, diff);
    } catch (e, st) {
      debugPrint('[LibraryIndexer] erro ao escanear ${folder.path}: $e\n$st');
    } finally {
      _setScanning(-1);
    }
    if (ref.mounted) unawaited(processQueue());
  }

  /// Processa a fila de extração com concorrência limitada.
  ///
  /// Se já estiver rodando, devolve a mesma execução (quem chama pode
  /// aguardar até a fila esvaziar) e marca para uma nova passada, cobrindo
  /// itens adicionados no fim da execução atual.
  Future<void> processQueue() {
    if (_queue != null) {
      _rerun = true;
      return _queue!;
    }
    return _queue = _runQueue().whenComplete(() => _queue = null);
  }

  Future<void> _runQueue() async {
    try {
      do {
        _rerun = false;
        await _drain();
      } while (_rerun && ref.mounted);
    } catch (e, st) {
      debugPrint('[LibraryIndexer] erro na fila: $e\n$st');
    } finally {
      _update((s) => s.copyWith(pendingProbe: 0));
    }
  }

  Future<void> _drain() async {
    while (ref.mounted) {
      final batch = (await _videos.pendingProbe(limit: 50))
          .where((v) => !_inFlight.contains(v.id))
          .toList();
      if (batch.isEmpty || !ref.mounted) return;
      _update((s) => s.copyWith(pendingProbe: batch.length));

      await _ensureProbers();
      final queue = List.of(batch);
      await Future.wait([
        for (final prober in List.of(_probers))
          () async {
            while (queue.isNotEmpty && ref.mounted) {
              await _waitWhilePlaying();
              if (queue.isEmpty || !ref.mounted) return;
              final v = queue.removeAt(0);
              _inFlight.add(v.id);
              try {
                final meta = await prober.probe(videoId: v.id, path: v.path);
                if (!ref.mounted) return;
                await _videos.saveMetadata(v.id, meta);
              } catch (e) {
                debugPrint('[LibraryIndexer] falha em ${v.path}: $e');
                if (ref.mounted) {
                  await _videos.saveMetadata(
                      v.id, const VideoMetadata(durationMs: 0));
                }
              } finally {
                _inFlight.remove(v.id);
                _update((s) => s.copyWith(
                    pendingProbe: (s.pendingProbe - 1).clamp(0, 1 << 30)));
              }
            }
          }(),
      ]);
    }
  }

  Future<void> _ensureProbers() async {
    final factory = ref.read(proberFactoryProvider);
    while (_probers.length < _concurrency) {
      _probers.add(await factory());
    }
  }

  /// Apaga o cache de miniaturas e agenda nova geração.
  Future<void> clearThumbnailCache() async {
    final dir = await thumbnailsDirectory();
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    await _videos.resetThumbnails();
    unawaited(processQueue());
  }

  void _watch(FolderRow folder) {
    if (_watchers.containsKey(folder.id)) return;
    final dir = Directory(folder.path);
    if (!dir.existsSync()) return;
    try {
      _watchers[folder.id] = dir.watch(recursive: true).listen(
        (_) {
          _debouncers[folder.id]?.cancel();
          _debouncers[folder.id] = Timer(const Duration(seconds: 2), () {
            rescanFolder(folder);
          });
        },
        onError: (Object e) {
          debugPrint('[LibraryIndexer] watch falhou em ${folder.path}: $e');
          _watchers.remove(folder.id);
        },
      );
    } catch (e) {
      debugPrint('[LibraryIndexer] não foi possível vigiar ${folder.path}: $e');
    }
  }

  void _setScanning(int delta) {
    _activeScans += delta;
    _update((s) => s.copyWith(scanning: _activeScans > 0));
  }

  /// Atualiza o estado só se o provider ainda estiver ativo.
  void _update(IndexerState Function(IndexerState s) change) {
    if (ref.mounted) state = change(state);
  }
}
