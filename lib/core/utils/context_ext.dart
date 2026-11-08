import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension ContextExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// Layout "largo": rail lateral, grades com várias colunas, Watch em duas
  /// colunas (Windows e tablets).
  bool get isWide => MediaQuery.sizeOf(this).width >= 840;

  void showSnack(String message) {
    ScaffoldMessenger.maybeOf(this)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
