import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra vermelha na base da miniatura indicando quanto já foi assistido.
class ProgressOverlay extends StatelessWidget {
  const ProgressOverlay({super.key, required this.progress, this.height = 4});

  /// 0–1. `null` ou 0 não desenha nada.
  final double? progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    if (p == null || p <= 0) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.white.withValues(alpha: 0.35)),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: p.clamp(0.0, 1.0),
            child: const ColoredBox(color: AppTheme.accent),
          ),
        ],
      ),
    );
  }
}
