import 'dart:io';

import 'package:flutter/material.dart';

import '../models/video_item.dart';
import '../theme/app_theme.dart';
import '../utils/context_ext.dart';
import 'duration_badge.dart';
import 'progress_overlay.dart';

/// Miniatura 16:9 com selo de duração e barra de progresso.
/// Mostra shimmer enquanto a miniatura ainda não foi gerada.
class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    super.key,
    required this.item,
    this.radius = AppTheme.thumbRadius,
    this.cacheWidth = 480,
    this.showBadge = true,
  });

  final VideoItem item;
  final double radius;

  /// Largura de decodificação (economiza memória em grades grandes).
  final int cacheWidth;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final v = item.video;
    final probing = v.durationMs == null && v.isAvailable;
    final thumb = v.thumbPath;

    Widget image;
    if (thumb != null) {
      image = Image.file(
        File(thumb),
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const _Placeholder(),
      );
    } else if (probing) {
      image = const Shimmer();
    } else {
      image = const _Placeholder();
    }

    if (!v.isAvailable) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: Opacity(opacity: 0.5, child: image),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.surfaceContainerHigh),
            image,
            if (showBadge)
              Positioned(
                right: 6,
                bottom: item.progress != null ? 10 : 6,
                child: DurationBadge(
                  duration: item.duration,
                  label: v.isAvailable ? null : context.l10n.unavailable,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ProgressOverlay(progress: item.progress),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => Center(
        child: Icon(
          Icons.movie_outlined,
          size: 36,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      );
}

/// Placeholder animado (efeito shimmer) sem dependências externas.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceContainerHigh;
    final highlight = context.colors.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 3 - 1; // -1 → 2
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(t - 1, -0.3),
              end: Alignment(t + 1, 0.3),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}
