import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/context_ext.dart';
import 'android_system.dart';

/// Permissões de leitura de vídeos no Android:
/// `READ_MEDIA_VIDEO` (API 33+) ou `READ_EXTERNAL_STORAGE` (API ≤ 32).
///
/// A permissão certa é escolhida pela versão do sistema. Não basta aceitar
/// "qualquer uma": no Android 13+ o status de `storage` não reflete o acesso
/// a vídeos, e sem `READ_MEDIA_VIDEO` o sistema esconde os arquivos ao
/// listar a pasta (o scan encontraria zero vídeos).
abstract final class AndroidPermissions {
  static Future<Permission> _videoPermission() async =>
      await AndroidSystem.sdkInt() >= 33 ? Permission.videos : Permission.storage;

  static Future<bool> hasVideoAccess() async {
    if (!Platform.isAndroid) return true;
    return (await _videoPermission()).isGranted;
  }

  /// Explica o motivo antes de pedir a permissão. Retorna `true` se concedida.
  static Future<bool> ensureVideoAccess(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    final permission = await _videoPermission();
    if (await permission.isGranted) return true;
    if (!context.mounted) return false;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.video_library_outlined),
        title: Text(ctx.l10n.permissionTitle),
        content: Text(ctx.l10n.permissionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.permissionContinue),
          ),
        ],
      ),
    );
    if (proceed != true) return false;

    final status = await permission.request();
    if (status.isGranted) return true;

    // Negada antes (ou "acesso limitado" a vídeos selecionados no
    // Android 14+): só dá para liberar nas configurações do sistema.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(context.l10n.permissionDenied),
          action: SnackBarAction(
            label: context.l10n.openSystemSettings,
            onPressed: openAppSettings,
          ),
        ),
      );
    }
    return false;
  }
}
