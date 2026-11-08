// Gera os PNGs do logo do LocalTube usados pelo flutter_launcher_icons.
//
// Uso: dart run tool/generate_icons.dart && dart run flutter_launcher_icons
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _red = (r: 0xE5, g: 0x39, b: 0x35);
const _dark = (r: 0x0F, g: 0x0F, b: 0x0F);

void main() {
  Directory('assets/logo').createSync(recursive: true);

  // Ícone completo: fundo escuro arredondado + "tela" vermelha + play branco.
  final full = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(full, color: img.ColorRgba8(0, 0, 0, 0));
  _roundedRect(full, 0, 0, 1024, 1024, 220, _dark);
  _drawMark(full, scale: 1.0);
  File('assets/logo/localtube_icon.png').writeAsBytesSync(img.encodePng(full));

  // Foreground do ícone adaptativo (Android): só a marca, com margem segura.
  final fg = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(fg, color: img.ColorRgba8(0, 0, 0, 0));
  _drawMark(fg, scale: 0.62);
  File('assets/logo/localtube_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Ícones gerados em assets/logo/');
}

/// Marca do LocalTube: retângulo vermelho em formato de "pasta" (aba no topo)
/// com um triângulo de play branco — remete a "vídeos nas suas pastas".
void _drawMark(img.Image image, {required double scale}) {
  final c = image.width / 2;
  final w = 720 * scale;
  final h = 500 * scale;
  final left = c - w / 2;
  final top = c - h / 2 + 30 * scale;

  // Aba da pasta.
  _roundedRect(image, left, top - 70 * scale, w * 0.42, 120 * scale,
      40 * scale, _red);
  // Corpo.
  _roundedRect(image, left, top, w, h, 70 * scale, _red);

  // Triângulo de play.
  final tri = <math.Point<double>>[
    math.Point(c - 95 * scale, top + h / 2 - 135 * scale),
    math.Point(c - 95 * scale, top + h / 2 + 135 * scale),
    math.Point(c + 145 * scale, top + h / 2),
  ];
  img.fillPolygon(
    image,
    vertices: [for (final p in tri) img.Point(p.x, p.y)],
    color: img.ColorRgba8(255, 255, 255, 255),
  );
}

void _roundedRect(img.Image image, double x, double y, double w, double h,
    double r, ({int r, int g, int b}) color) {
  final col = img.ColorRgba8(color.r, color.g, color.b, 255);
  img.fillRect(
    image,
    x1: x.round(),
    y1: y.round(),
    x2: (x + w).round(),
    y2: (y + h).round(),
    radius: r.round(),
    color: col,
  );
}
