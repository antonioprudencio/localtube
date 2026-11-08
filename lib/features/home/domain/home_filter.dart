import '../../../core/models/video_item.dart';

/// Filtros da linha de chips da tela Início.
sealed class HomeFilter {
  const HomeFilter();
}

class AllFilter extends HomeFilter {
  const AllFilter();
  @override
  bool operator ==(Object other) => other is AllFilter;
  @override
  int get hashCode => 0;
}

class ContinueWatchingFilter extends HomeFilter {
  const ContinueWatchingFilter();
  @override
  bool operator ==(Object other) => other is ContinueWatchingFilter;
  @override
  int get hashCode => 1;
}

class RecentFilter extends HomeFilter {
  const RecentFilter();
  @override
  bool operator ==(Object other) => other is RecentFilter;
  @override
  int get hashCode => 2;
}

class UnwatchedFilter extends HomeFilter {
  const UnwatchedFilter();
  @override
  bool operator ==(Object other) => other is UnwatchedFilter;
  @override
  int get hashCode => 3;
}

class FolderFilter extends HomeFilter {
  const FolderFilter(this.folderId);
  final int folderId;
  @override
  bool operator ==(Object other) =>
      other is FolderFilter && other.folderId == folderId;
  @override
  int get hashCode => Object.hash(4, folderId);
}

class FormatFilter extends HomeFilter {
  const FormatFilter(this.container);
  final String container;
  @override
  bool operator ==(Object other) =>
      other is FormatFilter && other.container == container;
  @override
  int get hashCode => Object.hash(5, container);
}

/// Janela considerada "recente".
const kRecentWindow = Duration(days: 30);

/// Aplica o filtro (função pura, testável).
List<VideoItem> applyHomeFilter(
  List<VideoItem> videos,
  HomeFilter filter, {
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  switch (filter) {
    case AllFilter():
      return videos;
    case ContinueWatchingFilter():
      final list = videos.where((v) => v.isInProgress).toList()
        ..sort((a, b) => (b.playback?.lastPlayedAt ?? DateTime(0))
            .compareTo(a.playback?.lastPlayedAt ?? DateTime(0)));
      return list;
    case RecentFilter():
      final list = videos
          .where((v) => n.difference(v.video.addedAt) <= kRecentWindow ||
              n.difference(v.video.modifiedAt) <= kRecentWindow)
          .toList()
        ..sort((a, b) => b.video.modifiedAt.compareTo(a.video.modifiedAt));
      return list;
    case UnwatchedFilter():
      return videos
          .where((v) => v.playback?.lastPlayedAt == null && !v.isCompleted)
          .toList();
    case FolderFilter(:final folderId):
      return videos.where((v) => v.video.folderId == folderId).toList();
    case FormatFilter(:final container):
      return videos.where((v) => v.video.container == container).toList();
  }
}
