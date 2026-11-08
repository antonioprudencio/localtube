import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/video_list_tile.dart';
import '../../player/presentation/open_video.dart';
import '../data/search_repository.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _term = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _term = value.trim());
    });
  }

  void _useTerm(String term) {
    _ctrl
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    setState(() => _term = term);
    ref.read(searchRepositoryProvider).add(term);
  }

  void _open(VideoItem item, List<VideoItem> results) {
    ref.read(searchRepositoryProvider).add(_term);
    openVideo(context, ref, item);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (v) => _useTerm(v.trim()),
        ),
        actions: [
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) => _ctrl.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: l.actionClear,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _term = '');
                    },
                  ),
          ),
        ],
      ),
      body: _term.isEmpty ? _history(context) : _results(context),
    );
  }

  Widget _history(BuildContext context) {
    final l = context.l10n;
    final history = ref.watch(searchHistoryProvider).value ?? const [];
    if (history.isEmpty) return const SizedBox.shrink();
    return ListView(
      children: [
        ListTile(
          title: Text(l.recentSearches, style: context.text.titleSmall),
          trailing: TextButton(
            onPressed: () => ref.read(searchRepositoryProvider).clear(),
            child: Text(l.actionClear),
          ),
        ),
        for (final term in history)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(term),
            onTap: () => _useTerm(term),
            trailing: IconButton(
              tooltip: l.actionRemove,
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => ref.read(searchRepositoryProvider).remove(term),
            ),
          ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_term));
    return switch (results) {
      AsyncData(:final value) when value.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(context.l10n.searchNoResults(_term)),
          ),
        ),
      AsyncData(:final value) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: value.length,
          itemBuilder: (context, i) => VideoListTile(
            key: ValueKey(value[i].id),
            item: value[i],
            onTap: () => _open(value[i], value),
          ),
        ),
      AsyncError(:final error) => Center(child: Text('$error')),
      _ => const LinearProgressIndicator(),
    };
  }
}
