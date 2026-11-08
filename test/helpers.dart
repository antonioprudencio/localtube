import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localtube/core/db/database.dart';
import 'package:localtube/core/models/video_item.dart';
import 'package:localtube/core/theme/app_theme.dart';
import 'package:localtube/l10n/app_localizations.dart';

/// Cria um banco em memória para testes.
AppDatabase testDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.memory();
}

/// [VideoItem] fictício para testes de UI/lógica pura.
VideoItem fakeVideo({
  int id = 1,
  int folderId = 1,
  String title = 'Meu vídeo de férias',
  String folderName = 'Viagens',
  int sizeBytes = 1288490189, // ~1,2 GB
  int? durationMs = 600000,
  int? width = 1920,
  int? height = 1080,
  String container = 'mp4',
  DateTime? modifiedAt,
  DateTime? addedAt,
  bool isAvailable = true,
  bool isFavorite = false,
  int? positionMs,
  bool completed = false,
  DateTime? lastPlayedAt,
}) {
  final now = DateTime.now();
  return VideoItem(
    video: VideoRow(
      id: id,
      folderId: folderId,
      path: '/videos/$folderName/$title.$container',
      fileName: '$title.$container',
      title: title,
      sizeBytes: sizeBytes,
      durationMs: durationMs,
      width: width,
      height: height,
      videoCodec: 'h264',
      audioCodec: 'aac',
      container: container,
      modifiedAt: modifiedAt ?? now.subtract(const Duration(days: 3)),
      addedAt: addedAt ?? now.subtract(const Duration(days: 3)),
      thumbPath: null,
      isFavorite: isFavorite,
      watchLater: false,
      isAvailable: isAvailable,
    ),
    folderName: folderName,
    playback: positionMs == null && !completed && lastPlayedAt == null
        ? null
        : PlaybackStateRow(
            videoId: id,
            positionMs: positionMs ?? 0,
            completed: completed,
            lastPlayedAt: lastPlayedAt ?? now,
            playCount: 1,
            audioTrack: null,
            subtitleTrack: null,
            speed: null,
          ),
  );
}

/// Envolve um widget com MaterialApp + localização pt + ProviderScope.
Widget testApp(
  Widget child, {
  List<Object> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.dark(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
