import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../data/playlist_repository.dart';
import 'playlist_name_dialog.dart';

/// "Salvar na playlist": lista as playlists com checkbox e permite criar nova.
class AddToPlaylistSheet extends ConsumerStatefulWidget {
  const AddToPlaylistSheet({super.key, required this.item});

  final VideoItem item;

  static Future<void> show(BuildContext context, VideoItem item) {
    if (context.isWide) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
            child: AddToPlaylistSheet(item: item),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => AddToPlaylistSheet(item: item),
    );
  }

  @override
  ConsumerState<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<AddToPlaylistSheet> {
  List<PlaylistRow>? _playlists;
  Set<int> _containing = {};

  PlaylistRepository get _repo => ref.read(playlistRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lists = await _repo.getPlaylists();
    final containing = await _repo.playlistsContaining(widget.item.id);
    if (!mounted) return;
    setState(() {
      _playlists = lists;
      _containing = containing;
    });
  }

  Future<void> _toggle(PlaylistRow p, bool add) async {
    if (add) {
      await _repo.addVideo(p.id, widget.item.id);
    } else {
      await _repo.removeVideo(p.id, widget.item.id);
    }
    setState(() => add ? _containing.add(p.id) : _containing.remove(p.id));
    if (mounted) {
      context.showSnack(add
          ? context.l10n.savedToPlaylist(p.name)
          : context.l10n.removedFromPlaylist(p.name));
    }
  }

  Future<void> _create() async {
    final name = await PlaylistNameDialog.show(context);
    if (name == null) return;
    final p = await _repo.create(name);
    await _repo.addVideo(p.id, widget.item.id);
    await _load();
    if (mounted) context.showSnack(context.l10n.savedToPlaylist(p.name));
  }

  @override
  Widget build(BuildContext context) {
    final lists = _playlists;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(context.l10n.menuAddToPlaylist,
              style: context.text.titleMedium),
        ),
        if (lists == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in lists)
                  CheckboxListTile(
                    value: _containing.contains(p.id),
                    title: Text(p.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) => _toggle(p, v ?? false),
                  ),
              ],
            ),
          ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(context.l10n.newPlaylist),
          onTap: _create,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
