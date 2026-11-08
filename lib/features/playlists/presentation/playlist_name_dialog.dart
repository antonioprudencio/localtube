import 'package:flutter/material.dart';

import '../../../core/utils/context_ext.dart';

/// Diálogo para criar/renomear playlist. Retorna o nome ou `null`.
class PlaylistNameDialog extends StatefulWidget {
  const PlaylistNameDialog({super.key, this.initial});

  final String? initial;

  static Future<String?> show(BuildContext context, {String? initial}) =>
      showDialog<String>(
        context: context,
        builder: (_) => PlaylistNameDialog(initial: initial),
      );

  @override
  State<PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<PlaylistNameDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l.newPlaylist : l.actionRename),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: l.playlistName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => FilledButton(
            onPressed: _ctrl.text.trim().isEmpty ? null : _submit,
            child: Text(widget.initial == null ? l.actionCreate : l.actionSave),
          ),
        ),
      ],
    );
  }
}
