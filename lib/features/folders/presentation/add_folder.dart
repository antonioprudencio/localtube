import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/android_permissions.dart';
import '../../../core/utils/context_ext.dart';
import '../domain/library_indexer.dart';

/// Pede permissão (Android), abre o seletor de pastas e indexa a escolhida.
Future<void> addFolderFlow(BuildContext context, WidgetRef ref) async {
  if (!await AndroidPermissions.ensureVideoAccess(context)) return;
  final path = await FilePicker.getDirectoryPath();
  if (path == null || !context.mounted) return;
  await addFolderPath(context, ref, path);
}

Future<void> addFolderPath(BuildContext context, WidgetRef ref, String path) async {
  if (!Directory(path).existsSync()) return;
  final indexer = ref.read(libraryIndexerProvider.notifier);
  final folder = await indexer.addFolder(path);
  if (context.mounted) context.showSnack(context.l10n.folderAdded(folder.name));
}
