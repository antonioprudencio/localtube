import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo do LocalTube: "pasta" vermelha com play + texto. Desenhado em código
/// (sem assets) para ficar nítido em qualquer tamanho.
class LocalTubeLogo extends StatelessWidget {
  const LocalTubeLogo({super.key, this.height = 24, this.showText = true});

  final double height;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: 'LocalTube',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: height * 1.4,
            height: height,
            child: const CustomPaint(painter: _MarkPainter()),
          ),
          if (showText) ...[
            SizedBox(width: height * 0.25),
            Text(
              'LocalTube',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: height * 0.85,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: color,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final red = Paint()..color = AppTheme.accent;

    // Aba da pasta.
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, w * 0.45, h * 0.35, Radius.circular(h * 0.1)),
      red,
    );
    // Corpo.
    canvas.drawRRect(
      RRect.fromLTRBR(0, h * 0.14, w, h, Radius.circular(h * 0.18)),
      red,
    );
    // Play.
    final cx = w / 2;
    final cy = h * 0.57;
    final s = h * 0.24;
    final path = Path()
      ..moveTo(cx - s * 0.75, cy - s)
      ..lineTo(cx - s * 0.75, cy + s)
      ..lineTo(cx + s, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
