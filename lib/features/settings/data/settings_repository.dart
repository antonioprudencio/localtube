import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/video_extensions.dart';
import '../domain/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'theme_mode';
  static const _kExt = 'extensions';
  static const _kMinSize = 'min_size_mb';
  static const _kAutoplay = 'autoplay_next';
  static const _kSpeed = 'default_speed';
  static const _kSubLang = 'subtitle_lang';
  static const _kAudioLang = 'audio_lang';
  static const _kHw = 'hw_accel';

  AppSettings load() {
    const d = AppSettings();
    final themeIndex = _prefs.getInt(_kTheme);
    return AppSettings(
      themeMode: themeIndex == null
          ? d.themeMode
          : ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
      extensions: (_prefs.getStringList(_kExt) ?? kVideoExtensions)
          .where(kVideoExtensions.contains)
          .toList(),
      minSizeMb: _prefs.getInt(_kMinSize) ?? d.minSizeMb,
      autoplayNext: _prefs.getBool(_kAutoplay) ?? d.autoplayNext,
      defaultSpeed: _prefs.getDouble(_kSpeed) ?? d.defaultSpeed,
      preferredSubtitleLang: _prefs.getString(_kSubLang) ?? d.preferredSubtitleLang,
      preferredAudioLang: _prefs.getString(_kAudioLang) ?? d.preferredAudioLang,
      hardwareAcceleration: _prefs.getBool(_kHw) ?? d.hardwareAcceleration,
    );
  }

  Future<void> save(AppSettings s) async {
    await Future.wait([
      _prefs.setInt(_kTheme, s.themeMode.index),
      _prefs.setStringList(_kExt, s.extensions),
      _prefs.setInt(_kMinSize, s.minSizeMb),
      _prefs.setBool(_kAutoplay, s.autoplayNext),
      _prefs.setDouble(_kSpeed, s.defaultSpeed),
      _prefs.setString(_kSubLang, s.preferredSubtitleLang),
      _prefs.setString(_kAudioLang, s.preferredAudioLang),
      _prefs.setBool(_kHw, s.hardwareAcceleration),
    ]);
  }
}
