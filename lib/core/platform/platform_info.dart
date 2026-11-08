import 'dart:io';

/// Atalhos para checagens de plataforma (o app roda só em Android e Windows).
abstract final class PlatformInfo {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isWindows => Platform.isWindows;

  /// Plataformas desktop (Windows; macOS/Linux só durante desenvolvimento).
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
