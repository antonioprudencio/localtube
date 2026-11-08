import '../db/database.dart';

/// Vídeo pronto para exibição: registro do vídeo + nome da pasta + progresso.
class VideoItem {
  const VideoItem({
    required this.video,
    required this.folderName,
    this.playback,
  });

  final VideoRow video;
  final String folderName;
  final PlaybackStateRow? playback;

  int get id => video.id;
  String get title => video.title;
  String get path => video.path;

  Duration? get duration =>
      (video.durationMs ?? 0) > 0 ? Duration(milliseconds: video.durationMs!) : null;

  /// Fração assistida (0–1), ou `null` se nunca foi assistido.
  double? get progress {
    final pb = playback;
    final d = video.durationMs;
    if (pb == null || d == null || d <= 0) return null;
    if (pb.completed) return 1;
    if (pb.positionMs <= 0) return null;
    return (pb.positionMs / d).clamp(0.0, 1.0);
  }

  bool get isCompleted => playback?.completed ?? false;

  bool get isInProgress {
    final pr = progress;
    return pr != null && pr > 0 && !isCompleted;
  }

  VideoItem copyWith({VideoRow? video, PlaybackStateRow? playback}) => VideoItem(
        video: video ?? this.video,
        folderName: folderName,
        playback: playback ?? this.playback,
      );

  @override
  bool operator ==(Object other) =>
      other is VideoItem &&
      other.video == video &&
      other.folderName == folderName &&
      other.playback == playback;

  @override
  int get hashCode => Object.hash(video, folderName, playback);
}
