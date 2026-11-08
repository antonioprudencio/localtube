import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/database.dart';
import 'core/platform/windows_window.dart';
import 'core/providers.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  WindowsWindow.init();

  LicenseRegistry.addLicense(() async* {
    final roboto = await rootBundle.loadString('assets/fonts/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['Roboto'], roboto);
  });

  final db = await AppDatabase.open();
  final prefs = await SharedPreferences.getInstance();

  // Windows: arquivo recebido via "Abrir com" / linha de comando.
  final launchFile = args.where((a) => !a.startsWith('-')).firstOrNull;

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        launchFileProvider.overrideWithValue(launchFile),
      ],
      child: const LocalTubeApp(),
    ),
  );
}
