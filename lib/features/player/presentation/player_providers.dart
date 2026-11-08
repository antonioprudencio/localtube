import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/video_item.dart';
import '../../../core/platform/android_system.dart';
import '../../library/data/video_repository.dart';

part 'player_providers.g.dart';

/// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).
@riverpod
Stream<VideoItem?> videoById(Ref ref, int id) =>
    ref.watch(videoRepositoryProvider).watchById(id);

/// `true` enquanto a tela Watch está aberta (o mini-player se esconde).
@Riverpod(keepAlive: true)
class WatchScreenVisible extends _$WatchScreenVisible {
  @override
  bool build() => false;

  void set(bool value) {
    if (state != value) state = value;
  }
}

/// Modo Picture-in-Picture do Android.
@Riverpod(keepAlive: true)
Stream<bool> pipMode(Ref ref) async* {
  yield false;
  yield* AndroidSystem.pipChanges;
}
