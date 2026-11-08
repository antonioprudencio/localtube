import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/database.dart';

part 'providers.g.dart';

/// Banco do app. É sobrescrito em `main.dart` (e nos testes) com a instância
/// já aberta.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) =>
    throw UnimplementedError('appDatabaseProvider deve ser sobrescrito');

/// `SharedPreferences` carregado na inicialização.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferencesProvider deve ser sobrescrito');

/// Arquivo passado na linha de comando ("Abrir com" no Windows).
@Riverpod(keepAlive: true)
String? launchFile(Ref ref) => null;
