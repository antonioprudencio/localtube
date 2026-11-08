import 'package:intl/intl.dart';

/// Formatações no padrão pt-BR usadas em toda a interface.
abstract final class Fmt {
  static final _oneDecimal = NumberFormat('#,##0.0', 'pt_BR');
  static final _noDecimal = NumberFormat('#,##0', 'pt_BR');

  /// `1,2 GB`, `850 MB`, `12 KB`.
  static String fileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final f = (unit >= 3 || value < 10) && unit > 0 ? _oneDecimal : _noDecimal;
    return '${f.format(value)} ${units[unit]}';
  }

  /// `1:02:03` ou `4:05`.
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
    return '$m:$ss';
  }

  /// Rótulo de resolução: `2160p (4K)`, `1080p`, `720p`…
  static String? resolution(int? width, int? height) {
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    // Usa o menor lado para tratar vídeos verticais corretamente.
    final short = width < height ? width : height;
    const steps = [4320, 2160, 1440, 1080, 720, 480, 360, 240, 144];
    for (final s in steps) {
      if (short >= s * 0.9) {
        if (s == 2160) return '2160p (4K)';
        if (s == 4320) return '4320p (8K)';
        return '${s}p';
      }
    }
    return '${short}p';
  }

  /// `há 3 dias`, `há 2 meses`, `agora mesmo`.
  static String relative(DateTime date, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(date);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inHours < 1) return _plural(diff.inMinutes, 'minuto', 'minutos');
    if (diff.inDays < 1) return _plural(diff.inHours, 'hora', 'horas');
    if (diff.inDays < 7) return _plural(diff.inDays, 'dia', 'dias');
    if (diff.inDays < 30) {
      return _plural(diff.inDays ~/ 7, 'semana', 'semanas');
    }
    if (diff.inDays < 365) return _plural(diff.inDays ~/ 30, 'mês', 'meses');
    return _plural(diff.inDays ~/ 365, 'ano', 'anos');
  }

  static String _plural(int n, String one, String many) =>
      'há $n ${n == 1 ? one : many}';

  /// Taxa de bits aproximada a partir do tamanho e da duração.
  static String? bitrate(int sizeBytes, int? durationMs) {
    if (durationMs == null || durationMs <= 0) return null;
    final bps = sizeBytes * 8 / (durationMs / 1000);
    if (bps >= 1e6) return '${_oneDecimal.format(bps / 1e6)} Mb/s';
    return '${_noDecimal.format(bps / 1e3)} kb/s';
  }

  static String dateTime(DateTime d) =>
      DateFormat('dd/MM/yyyy HH:mm').format(d);

  static String speed(double s) =>
      s == 1 ? 'Normal' : '${NumberFormat('0.##', 'pt_BR').format(s)}×';
}
