import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/models/video_item.dart';
import '../../../core/platform/android_system.dart';
import '../../../core/platform/windows_window.dart';
import '../../library/data/video_repository.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/playback_repository.dart';
import 'player_session.dart';

part 'player_controller.g.dart';

/// Controlador único de reprodução. O mesmo [Player] é usado pela tela
/// Watch e pelo mini-player, então a reprodução continua ao navegar.
@Riverpod(keepAlive: true)
class PlayerController extends _$PlayerController {
  late final Player player;
  late final VideoController videoController;

  final _subs = <StreamSubscription<Object?>>[];
  Timer? _saveTimer;
  bool _opening = false;

  static const speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _resumeMinimum = Duration(seconds: 5);
  static const _saveInterval = Duration(seconds: 5);

  PlaybackRepository get _playback => ref.read(playbackRepositoryProvider);

  @override
  PlayerSession build() {
    final settings = ref.read(settingsProvider);
    player = Player(
      configuration: const PlayerConfiguration(
        title: 'LocalTube',
        logLevel: kDebugMode ? MPVLogLevel.warn : MPVLogLevel.error,
      ),
    );
    videoController = VideoController(
      player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: settings.hardwareAcceleration,
      ),
    );
    _configureMpv(
      subLang: settings.preferredSubtitleLang,
      audioLang: settings.preferredAudioLang,
    );

    _subs
      ..add(player.stream.completed.listen((done) {
        if (done) _onCompleted();
      }))
      ..add(player.stream.error.listen(_onError))
      ..add(player.stream.playing.listen(_onPlayingChanged));
    if (kDebugMode) {
      _subs.add(player.stream.log.listen((l) => debugPrint('[mpv] $l')));
    }

    ref.onDispose(() {
      _saveTimer?.cancel();
      for (final s in _subs) {
        s.cancel();
      }
      player.dispose();
    });

    return PlayerSession(autoplay: settings.autoplayNext);
  }

  NativePlayer? get _native =>
      player.platform is NativePlayer ? player.platform as NativePlayer : null;

  Future<void> _configureMpv({String subLang = '', String audioLang = ''}) async {
    final n = _native;
    if (n == null) return;
    try {
      // Carrega automaticamente legendas externas com o mesmo nome do vídeo
      // (.srt, .ass/.ssa, .vtt) na mesma pasta.
      await n.setProperty('sub-auto', 'exact');
      await n.setProperty('sub-file-paths', '.');
      if (subLang.trim().isNotEmpty) await n.setProperty('slang', subLang);
      if (audioLang.trim().isNotEmpty) await n.setProperty('alang', audioLang);
    } catch (e) {
      debugPrint('[PlayerController] configuração do mpv: $e');
    }
  }

  /// Aplica as preferências de idioma das configurações.
  Future<void> applyLanguagePreferences() async {
    final s = ref.read(settingsProvider);
    await _configureMpv(
      subLang: s.preferredSubtitleLang,
      audioLang: s.preferredAudioLang,
    );
  }

  // ---------------------------------------------------------------------------
  // Abertura e fila
  // ---------------------------------------------------------------------------

  /// Reproduz [item]. Se [queue] não for informada, usa os vídeos da mesma
  /// pasta (em ordem alfabética) como lista "A seguir".
  Future<void> play(VideoItem item, {List<VideoItem>? queue}) async {
    var list = queue;
    if (list == null || list.isEmpty) {
      list = await ref
          .read(videoRepositoryProvider)
          .folderVideos(item.video.folderId);
    }
    var index = list.indexWhere((v) => v.id == item.id);
    if (index < 0) {
      list = [item, ...list];
      index = 0;
    }
    await _openAt(list, index);
  }

  /// Reproduz uma fila a partir do início (playlists: "Tocar tudo"/"Aleatório").
  Future<void> playAll(List<VideoItem> items, {bool shuffle = false}) async {
    if (items.isEmpty) return;
    final list = List.of(items);
    if (shuffle) list.shuffle(math.Random());
    await _openAt(list, 0);
  }

  Future<void> _openAt(List<VideoItem> queue, int index) async {
    if (_opening) return;
    _opening = true;
    try {
      await _saveProgress();
      final item = queue[index];
      state = state.copyWith(queue: queue, index: index, error: () => null);
      WindowsWindow.setVideoTitle(item.title);

      if (!await File(item.path).exists()) {
        await player.stop();
        state = state.copyWith(error: () => PlayerErrorKind.unavailable);
        return;
      }

      final saved = await _playback.get(item.id);
      Duration? start;
      final durationMs = item.video.durationMs ?? 0;
      if (saved != null && !saved.completed) {
        final pos = Duration(milliseconds: saved.positionMs);
        final nearEnd = durationMs > 0 &&
            saved.positionMs >= durationMs * PlaybackRepository.completedThreshold;
        if (pos >= _resumeMinimum && !nearEnd) start = pos;
      }

      await player.open(Media(item.path, start: start));
      final speed = saved?.speed ?? ref.read(settingsProvider).defaultSpeed;
      await player.setRate(speed);
      if (state.subtitleDelay != 0) {
        await _native?.setProperty('sub-delay', '${state.subtitleDelay}');
      }
      await _playback.markStarted(item.id);
      _restoreTrackPreferences(saved?.audioTrack, saved?.subtitleTrack);
    } catch (e, st) {
      debugPrint('[PlayerController] falha ao abrir: $e\n$st');
      state = state.copyWith(error: () => PlayerErrorKind.unplayable);
    } finally {
      _opening = false;
    }
  }

  /// Quando as faixas forem carregadas, reaplica as escolhidas anteriormente.
  void _restoreTrackPreferences(String? audioId, String? subtitleId) {
    if (audioId == null && subtitleId == null) return;
    late StreamSubscription<Tracks> sub;
    sub = player.stream.tracks.listen((tracks) {
      if (tracks.audio.length <= 2 && tracks.subtitle.length <= 2) return;
      sub.cancel();
      final audio = tracks.audio.where((t) => t.id == audioId).firstOrNull;
      if (audio != null) player.setAudioTrack(audio);
      final sub_ = tracks.subtitle.where((t) => t.id == subtitleId).firstOrNull;
      if (sub_ != null) player.setSubtitleTrack(sub_);
    });
    Future.delayed(const Duration(seconds: 5), sub.cancel);
  }

  Future<void> next({bool auto = false}) async {
    final s = state;
    if (s.queue.isEmpty) return;
    var nextIndex = s.index + 1;
    if (nextIndex >= s.queue.length) {
      if (s.repeat != LoopMode.all) return;
      nextIndex = 0;
    }
    await _openAt(s.queue, nextIndex);
  }

  Future<void> previous() async {
    if (player.state.position > const Duration(seconds: 3) ||
        state.index <= 0) {
      await player.seek(Duration.zero);
      return;
    }
    await _openAt(state.queue, state.index - 1);
  }

  Future<void> playFromQueue(int queueIndex) async {
    if (queueIndex < 0 || queueIndex >= state.queue.length) return;
    await _openAt(state.queue, queueIndex);
  }

  /// Para a reprodução e fecha o mini-player.
  Future<void> close() async {
    await _saveProgress();
    await player.stop();
    await exitFullscreen();
    state = state.copyWith(queue: const [], index: -1, error: () => null);
    WindowsWindow.setVideoTitle(null);
    await AndroidSystem.setAutoPip(false);
  }

  // ---------------------------------------------------------------------------
  // Eventos do player
  // ---------------------------------------------------------------------------

  Future<void> _onCompleted() async {
    final item = state.current;
    if (item == null) return;
    await _playback.setCompleted(item.id, true);
    switch (state.repeat) {
      case LoopMode.one:
        await player.seek(Duration.zero);
        await player.play();
      case LoopMode.all:
        await next(auto: true);
      case LoopMode.off:
        if (state.autoplay && state.index + 1 < state.queue.length) {
          await next(auto: true);
        }
    }
  }

  void _onError(String message) {
    debugPrint('[PlayerController] erro do mpv: $message');
    // Erros durante a abertura indicam formato não suportado/arquivo corrompido.
    if (player.state.duration == Duration.zero && state.hasVideo) {
      state = state.copyWith(error: () => PlayerErrorKind.unplayable);
    }
  }

  void _onPlayingChanged(bool playing) {
    _saveTimer?.cancel();
    if (playing) {
      _saveTimer = Timer.periodic(_saveInterval, (_) => _saveProgress());
      WakelockPlus.enable().catchError((_) {});
    } else {
      _saveProgress();
      WakelockPlus.disable().catchError((_) {});
    }
    AndroidSystem.setAutoPip(playing);
  }

  Future<void> _saveProgress() async {
    final item = state.current;
    if (item == null) return;
    final pos = player.state.position;
    final dur = player.state.duration;
    if (dur <= Duration.zero) return;
    try {
      await _playback.savePosition(item.id, position: pos, duration: dur);
    } catch (e) {
      debugPrint('[PlayerController] salvar progresso: $e');
    }
  }

  /// Chamado ao sair da tela/fechar o app.
  Future<void> saveNow() => _saveProgress();

  // ---------------------------------------------------------------------------
  // Controles
  // ---------------------------------------------------------------------------

  Future<void> togglePlay() => player.playOrPause();

  Future<void> seek(Duration position) {
    final dur = player.state.duration;
    var target = position < Duration.zero ? Duration.zero : position;
    if (dur > Duration.zero && target > dur) target = dur;
    return player.seek(target);
  }

  Future<void> seekRelative(Duration offset) =>
      seek(player.state.position + offset);

  /// Pula para uma fração da duração (teclas 0–9).
  Future<void> seekFraction(double fraction) =>
      seek(player.state.duration * fraction.clamp(0.0, 1.0));

  Future<void> setRate(double rate) async {
    await player.setRate(rate);
    final item = state.current;
    if (item != null) await _playback.savePreferences(item.id, speed: rate);
  }

  Future<void> stepRate(int direction) {
    final current = player.state.rate;
    var i = speeds.indexWhere((s) => s >= current - 0.001);
    if (i < 0) i = speeds.indexOf(1.0);
    final next = (i + direction).clamp(0, speeds.length - 1);
    return setRate(speeds[next]);
  }

  double _volumeBeforeMute = 100;

  Future<void> setVolume(double volume) => player.setVolume(volume.clamp(0, 100));

  Future<void> changeVolume(double delta) =>
      setVolume(player.state.volume + delta);

  Future<void> toggleMute() async {
    if (player.state.volume > 0) {
      _volumeBeforeMute = player.state.volume;
      await player.setVolume(0);
    } else {
      await player.setVolume(_volumeBeforeMute == 0 ? 100 : _volumeBeforeMute);
    }
  }

  void setFit(VideoFit fit) => state = state.copyWith(fit: fit);

  void cycleFit() => state = state.copyWith(
      fit: VideoFit.values[(state.fit.index + 1) % VideoFit.values.length]);

  void setRepeat(LoopMode mode) => state = state.copyWith(repeat: mode);

  void cycleRepeat() => state = state.copyWith(
      repeat: LoopMode.values[(state.repeat.index + 1) % LoopMode.values.length]);

  void setAutoplay(bool value) => state = state.copyWith(autoplay: value);

  void setLocked(bool value) => state = state.copyWith(locked: value);

  void toggleTheater() => state = state.copyWith(theater: !state.theater);

  Future<void> setAudioTrack(AudioTrack track) async {
    await player.setAudioTrack(track);
    final item = state.current;
    if (item != null) {
      await _playback.savePreferences(item.id, audioTrack: track.id);
    }
  }

  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await player.setSubtitleTrack(track);
    final item = state.current;
    if (item != null && !track.uri && !track.data) {
      await _playback.savePreferences(item.id, subtitleTrack: track.id);
    }
  }

  /// Liga/desliga legendas (tecla C).
  Future<void> toggleSubtitles() async {
    final current = player.state.track.subtitle;
    if (current.id != 'no') {
      await setSubtitleTrack(SubtitleTrack.no());
      return;
    }
    final first = player.state.tracks.subtitle
        .where((t) => t.id != 'no' && t.id != 'auto')
        .firstOrNull;
    await setSubtitleTrack(first ?? SubtitleTrack.auto());
  }

  Future<void> loadExternalSubtitle(String path) =>
      player.setSubtitleTrack(SubtitleTrack.uri(path));

  Future<void> setSubtitleDelay(double seconds) async {
    state = state.copyWith(subtitleDelay: seconds);
    await _native?.setProperty('sub-delay', seconds.toStringAsFixed(2));
  }

  // ---------------------------------------------------------------------------
  // Tela cheia
  // ---------------------------------------------------------------------------

  /// [forceLandscape]: trava a orientação em paisagem (botão de tela cheia).
  /// Quando a tela cheia vem da rotação do aparelho, a orientação fica livre
  /// para que girar de volta para retrato saia da tela cheia.
  Future<void> enterFullscreen({bool forceLandscape = true}) async {
    if (state.fullscreen) return;
    state = state.copyWith(fullscreen: true);
    WindowsWindow.setFullScreen(true);
    final w = player.state.width ?? 16;
    final h = player.state.height ?? 9;
    await AndroidSystem.enterFullscreen(landscape: forceLandscape && w >= h);
  }

  Future<void> exitFullscreen() async {
    if (!state.fullscreen) return;
    state = state.copyWith(fullscreen: false, locked: false);
    WindowsWindow.setFullScreen(false);
    await AndroidSystem.exitFullscreen();
  }

  Future<void> toggleFullscreen() =>
      state.fullscreen ? exitFullscreen() : enterFullscreen();

  Future<void> enterPip() async {
    final w = player.state.width ?? 16;
    final h = player.state.height ?? 9;
    await AndroidSystem.enterPip(width: w, height: h);
  }
}
