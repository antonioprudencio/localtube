import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/models/video_item.dart';
import '../../../core/utils/video_extensions.dart';
import '../../folders/data/folder_repository.dart';
import '../../folders/domain/library_indexer.dart';
import '../../library/data/video_repository.dart';
import '../domain/player_controller.dart';

/// Abre um arquivo vindo de fora do app ("Abrir com" no Windows ou arquivo
/// arrastado para a janela). Se ainda não estiver na biblioteca, a pasta do
/// arquivo é adicionada (assim histórico, progresso e "A seguir" funcionam).
///
/// Retorna o vídeo aberto, ou `null` se não for um vídeo suportado.
Future<VideoItem?> openExternalFile(WidgetRef ref, String path) async {
  if (!isVideoFile(path) || !File(path).existsSync()) return null;
  final videos = ref.read(videoRepositoryProvider);

  var item = await videos.getByPath(path);
  if (item == null) {
    try {
      final folder =
          await ref.read(folderRepositoryProvider).addFolder(p.dirname(path));
      await ref.read(libraryIndexerProvider.notifier).rescanFolder(folder);
      item = await videos.getByPath(path);
    } catch (e) {
      debugPrint('[openExternalFile] $e');
    }
  }
  if (item == null) return null;
  await ref.read(playerControllerProvider.notifier).play(item);
  return item;
}
