import 'package:flutter/material.dart';

import '../../../core/utils/video_extensions.dart';

/// Configurações simples do app, persistidas em `shared_preferences`.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.extensions = kVideoExtensions,
    this.minSizeMb = 0,
    this.autoplayNext = true,
    this.defaultSpeed = 1.0,
    this.preferredSubtitleLang = 'por',
    this.preferredAudioLang = '',
    this.hardwareAcceleration = true,
  });

  final ThemeMode themeMode;
  final List<String> extensions;

  /// Ignorar arquivos menores que este tamanho (MB). 0 = não ignora.
  final int minSizeMb;
  final bool autoplayNext;
  final double defaultSpeed;

  /// Códigos de idioma separados por vírgula, no formato do mpv (`por,pt,eng`).
  final String preferredSubtitleLang;
  final String preferredAudioLang;
  final bool hardwareAcceleration;

  int get minSizeBytes => minSizeMb * 1024 * 1024;

  AppSettings copyWith({
    ThemeMode? themeMode,
    List<String>? extensions,
    int? minSizeMb,
    bool? autoplayNext,
    double? defaultSpeed,
    String? preferredSubtitleLang,
    String? preferredAudioLang,
    bool? hardwareAcceleration,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        extensions: extensions ?? this.extensions,
        minSizeMb: minSizeMb ?? this.minSizeMb,
        autoplayNext: autoplayNext ?? this.autoplayNext,
        defaultSpeed: defaultSpeed ?? this.defaultSpeed,
        preferredSubtitleLang:
            preferredSubtitleLang ?? this.preferredSubtitleLang,
        preferredAudioLang: preferredAudioLang ?? this.preferredAudioLang,
        hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      );
}
