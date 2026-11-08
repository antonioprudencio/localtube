import '../../../core/models/video_item.dart';

enum HistoryGroup { today, yesterday, thisWeek, older }

/// Agrupa o histórico por data da última reprodução (mantém a ordem).
Map<HistoryGroup, List<VideoItem>> groupHistory(
  List<VideoItem> items, {
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = today.subtract(const Duration(days: 7));

  final result = <HistoryGroup, List<VideoItem>>{};
  for (final item in items) {
    final at = item.playback?.lastPlayedAt;
    if (at == null) continue;
    final group = !at.isBefore(today)
        ? HistoryGroup.today
        : !at.isBefore(yesterday)
            ? HistoryGroup.yesterday
            : !at.isBefore(weekStart)
                ? HistoryGroup.thisWeek
                : HistoryGroup.older;
    (result[group] ??= []).add(item);
  }
  return {
    for (final g in HistoryGroup.values)
      if (result[g] != null) g: result[g]!,
  };
}
