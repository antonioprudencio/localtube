import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/video_item.dart';
import '../../../core/router/routes.dart';
import '../domain/player_controller.dart';

/// Inicia a reprodução e abre a tela Watch.
Future<void> openVideo(
  BuildContext context,
  WidgetRef ref,
  VideoItem item, {
  List<VideoItem>? queue,
}) async {
  final controller = ref.read(playerControllerProvider.notifier);
  final playing = controller.play(item, queue: queue);
  if (context.mounted) openWatchScreen(context);
  await playing;
}

/// Abre a tela Watch para o vídeo atual (sem empilhar duas vezes).
void openWatchScreen(BuildContext context) {
  final router = GoRouter.of(context);
  final location = router.routerDelegate.currentConfiguration.uri.path;
  if (location != Routes.watch) router.push(Routes.watch);
}
