import 'package:flutter/foundation.dart';

import '../../../core/models/video_item.dart';

enum LoopMode { off, one, all }

/// Proporção/ajuste do vídeo na tela.
enum VideoFit { fit, fill, ratio16x9, ratio4x3 }

enum PlayerErrorKind { unavailable, unplayable }

/// Estado da sessão de reprodução (o que está tocando e como).
/// Posição, duração e buffer vêm direto dos streams do `Player`.
@immutable
class PlayerSession {
  const PlayerSession({
    this.queue = const [],
    this.index = -1,
    this.repeat = LoopMode.off,
    this.autoplay = true,
    this.fit = VideoFit.fit,
    this.error,
    this.theater = false,
    this.fullscreen = false,
    this.subtitleDelay = 0,
    this.locked = false,
  });

  final List<VideoItem> queue;
  final int index;
  final LoopMode repeat;
  final bool autoplay;
  final VideoFit fit;
  final PlayerErrorKind? error;
  final bool theater;
  final bool fullscreen;

  /// Atraso da legenda em segundos (pode ser negativo).
  final double subtitleDelay;

  /// Controles bloqueados (Android).
  final bool locked;

  VideoItem? get current =>
      index >= 0 && index < queue.length ? queue[index] : null;

  bool get hasVideo => current != null;
  bool get hasNext => index + 1 < queue.length || repeat == LoopMode.all;
  bool get hasPrevious => index > 0;

  List<VideoItem> get upNext =>
      index < 0 ? const [] : queue.sublist((index + 1).clamp(0, queue.length));

  PlayerSession copyWith({
    List<VideoItem>? queue,
    int? index,
    LoopMode? repeat,
    bool? autoplay,
    VideoFit? fit,
    PlayerErrorKind? Function()? error,
    bool? theater,
    bool? fullscreen,
    double? subtitleDelay,
    bool? locked,
  }) =>
      PlayerSession(
        queue: queue ?? this.queue,
        index: index ?? this.index,
        repeat: repeat ?? this.repeat,
        autoplay: autoplay ?? this.autoplay,
        fit: fit ?? this.fit,
        error: error != null ? error() : this.error,
        theater: theater ?? this.theater,
        fullscreen: fullscreen ?? this.fullscreen,
        subtitleDelay: subtitleDelay ?? this.subtitleDelay,
        locked: locked ?? this.locked,
      );
}
