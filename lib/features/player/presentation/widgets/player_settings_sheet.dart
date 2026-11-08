import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/video_extensions.dart';
import '../../domain/player_controller.dart';
import '../../domain/player_session.dart';

enum _Page { root, speed, subtitles, audio, aspect, repeat }

/// Painel de configurações do player: velocidade, legendas (incluindo
/// arquivo externo e atraso), faixa de áudio, proporção e repetição.
class PlayerSettingsSheet extends ConsumerStatefulWidget {
  const PlayerSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (context.isWide || MediaQuery.orientationOf(context) == Orientation.landscape) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
            child: const PlayerSettingsSheet(),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PlayerSettingsSheet(),
    );
  }

  @override
  ConsumerState<PlayerSettingsSheet> createState() => _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends ConsumerState<PlayerSettingsSheet> {
  _Page _page = _Page.root;

  PlayerController get _ctrl => ref.read(playerControllerProvider.notifier);
  Player get _player => _ctrl.player;

  String _trackLabel(String id, String? title, String? language, int index) {
    final l = context.l10n;
    if (id == 'no') return l.subtitlesOff;
    if (id == 'auto') return l.subtitlesAuto;
    final parts = [?title, if (language != null) language.toUpperCase()];
    return parts.isEmpty ? l.trackN(index) : parts.join(' · ');
  }

  String _fitLabel(VideoFit f) => switch (f) {
        VideoFit.fit => context.l10n.aspectFit,
        VideoFit.fill => context.l10n.aspectFill,
        VideoFit.ratio16x9 => '16:9',
        VideoFit.ratio4x3 => '4:3',
      };

  String _repeatLabel(LoopMode r) => switch (r) {
        LoopMode.off => context.l10n.repeatOff,
        LoopMode.one => context.l10n.repeatOne,
        LoopMode.all => context.l10n.repeatAll,
      };

  Future<void> _pickSubtitle() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: kSubtitleExtensions,
    );
    final path = files.isEmpty ? null : files.single.path;
    if (path != null) await _ctrl.loadExternalSubtitle(path);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    final l = context.l10n;

    Widget back(String title) => ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(title, style: context.text.titleMedium),
          onTap: () => setState(() => _page = _Page.root),
        );

    Widget check(bool selected, String label, VoidCallback onTap) => ListTile(
          leading: Icon(selected ? Icons.check : null),
          title: Text(label),
          selected: selected,
          onTap: onTap,
        );

    final List<Widget> children;
    switch (_page) {
      case _Page.root:
        final state = _player.state;
        children = [
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l.speed),
            trailing: Text(Fmt.speed(state.rate)),
            onTap: () => setState(() => _page = _Page.speed),
          ),
          ListTile(
            leading: const Icon(Icons.closed_caption_outlined),
            title: Text(l.subtitles),
            trailing: Text(_trackLabel(state.track.subtitle.id,
                state.track.subtitle.title, state.track.subtitle.language, 1)),
            onTap: () => setState(() => _page = _Page.subtitles),
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack_outlined),
            title: Text(l.audioTrack),
            trailing: Text(_trackLabel(state.track.audio.id,
                state.track.audio.title, state.track.audio.language, 1)),
            onTap: () => setState(() => _page = _Page.audio),
          ),
          ListTile(
            leading: const Icon(Icons.aspect_ratio),
            title: Text(l.aspect),
            trailing: Text(_fitLabel(session.fit)),
            onTap: () => setState(() => _page = _Page.aspect),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(l.watchRepeat),
            trailing: Text(_repeatLabel(session.repeat)),
            onTap: () => setState(() => _page = _Page.repeat),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.skip_next_outlined),
            title: Text(l.autoplay),
            value: session.autoplay,
            onChanged: _ctrl.setAutoplay,
          ),
        ];
      case _Page.speed:
        children = [
          back(l.speed),
          for (final s in PlayerController.speeds)
            check((_player.state.rate - s).abs() < 0.01, Fmt.speed(s), () {
              _ctrl.setRate(s);
              setState(() => _page = _Page.root);
            }),
        ];
      case _Page.subtitles:
        final tracks = _player.state.tracks.subtitle;
        final current = _player.state.track.subtitle;
        children = [
          back(l.subtitles),
          for (final (i, t) in tracks.indexed)
            check(t.id == current.id, _trackLabel(t.id, t.title, t.language, i - 1),
                () {
              _ctrl.setSubtitleTrack(t);
              setState(() => _page = _Page.root);
            }),
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: Text(l.loadSubtitle),
            onTap: _pickSubtitle,
          ),
          const Divider(),
          ListTile(
            title: Text(l.subtitleDelay),
            subtitle: Text(l.seconds(session.subtitleDelay.toStringAsFixed(1))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '−0,1 s',
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      _ctrl.setSubtitleDelay(session.subtitleDelay - 0.1),
                ),
                IconButton(
                  tooltip: '0',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => _ctrl.setSubtitleDelay(0),
                ),
                IconButton(
                  tooltip: '+0,1 s',
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      _ctrl.setSubtitleDelay(session.subtitleDelay + 0.1),
                ),
              ],
            ),
          ),
        ];
      case _Page.audio:
        final tracks =
            _player.state.tracks.audio.where((t) => t.id != 'no').toList();
        final current = _player.state.track.audio;
        children = [
          back(l.audioTrack),
          for (final (i, t) in tracks.indexed)
            check(t.id == current.id, _trackLabel(t.id, t.title, t.language, i),
                () {
              _ctrl.setAudioTrack(t);
              setState(() => _page = _Page.root);
            }),
        ];
      case _Page.aspect:
        children = [
          back(l.aspect),
          for (final f in VideoFit.values)
            check(session.fit == f, _fitLabel(f), () {
              _ctrl.setFit(f);
              setState(() => _page = _Page.root);
            }),
        ];
      case _Page.repeat:
        children = [
          back(l.watchRepeat),
          for (final r in LoopMode.values)
            check(session.repeat == r, _repeatLabel(r), () {
              _ctrl.setRepeat(r);
              setState(() => _page = _Page.root);
            }),
        ];
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      children: children,
    );
  }
}
