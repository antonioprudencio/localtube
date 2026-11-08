import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/context_ext.dart';

/// Permissões de leitura de vídeos no Android:
/// `READ_MEDIA_VIDEO` (API 33+) ou `READ_EXTERNAL_STORAGE` (API ≤ 32).
abstract final class AndroidPermissions {
  static Future<bool> hasVideoAccess() async {
    if (!Platform.isAndroid) return true;
    return await Permission.videos.isGranted ||
        await Permission.storage.isGranted;
  }

  /// Explica o motivo antes de pedir a permissão. Retorna `true` se concedida.
  static Future<bool> ensureVideoAccess(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    if (await hasVideoAccess()) return true;
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

    // Em API 33+ só READ_MEDIA_VIDEO tem efeito; em ≤ 32 só storage.
    // Pedir as duas e aceitar qualquer uma cobre as duas faixas.
    final statuses = await [Permission.videos, Permission.storage].request();
    final granted = statuses.values.any((s) => s.isGranted || s.isLimited);
    if (granted) return true;

    final permanentlyDenied = statuses.values.any((s) => s.isPermanentlyDenied);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.permissionDenied),
          action: permanentlyDenied
              ? SnackBarAction(
                  label: context.l10n.openSystemSettings,
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
    }
    return false;
  }
}
