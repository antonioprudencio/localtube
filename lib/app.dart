import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' show AppExitResponse;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/folders/domain/library_indexer.dart';
import 'features/player/domain/player_controller.dart';
import 'features/player/presentation/open_external.dart';
import 'features/player/presentation/open_video.dart';
import 'features/player/presentation/player_providers.dart';
import 'features/settings/presentation/settings_providers.dart';
import 'l10n/app_localizations.dart';

/// Widget raiz do LocalTube.
class LocalTubeApp extends ConsumerStatefulWidget {
  const LocalTubeApp({super.key});

  @override
  ConsumerState<LocalTubeApp> createState() => _LocalTubeAppState();
}

class _LocalTubeAppState extends ConsumerState<LocalTubeApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: _onHide,
      onExitRequested: () async {
        await ref.read(playerControllerProvider.notifier).saveNow();
        return AppExitResponse.exit;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _startup() async {
    // Detecta arquivos novos/removidos/alterados a cada abertura.
    unawaited(ref.read(libraryIndexerProvider.notifier).startup());

    // Windows: aberto via "Abrir com" / linha de comando.
    final launchFile = ref.read(launchFileProvider);
    if (launchFile != null) {
      final item = await openExternalFile(ref, launchFile);
      final ctx = ref.read(appRouterProvider).routerDelegate.navigatorKey.currentContext;
      if (item != null && ctx != null && ctx.mounted) openWatchScreen(ctx);
    }
  }

  /// App foi para segundo plano (Android: atividade parada, não PiP).
  void _onHide() {
    final ctrl = ref.read(playerControllerProvider.notifier);
    ctrl.saveNow();
    final inPip = ref.read(pipModeProvider).value ?? false;
    if (Platform.isAndroid && !inPip) ctrl.player.pause();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    return MaterialApp.router(
      title: 'LocalTube',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => _PipAware(child: child!),
    );
  }
}

/// Em Picture-in-Picture, mostra só o vídeo (sem controles nem navegação).
class _PipAware extends ConsumerWidget {
  const _PipAware({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.watch(pipModeProvider).value ?? false;
    final hasVideo = ref.watch(playerControllerProvider.select((s) => s.hasVideo));
    if (!pip || !hasVideo) return child;
    final ctrl = ref.read(playerControllerProvider.notifier);
    return ColoredBox(
      color: Colors.black,
      child: Video(
        controller: ctrl.videoController,
        controls: NoVideoControls,
        wakelock: false,
        pauseUponEnteringBackgroundMode: false,
      ),
    );
  }
}
