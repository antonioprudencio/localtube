import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Selo de duração no canto da miniatura (ex.: `12:34`).
class DurationBadge extends StatelessWidget {
  const DurationBadge({super.key, required this.duration, this.label});

  final Duration? duration;

  /// Texto alternativo (ex.: "Indisponível").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label ?? (duration == null ? null : Fmt.duration(duration!));
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}
