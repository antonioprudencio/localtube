import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_item.dart';
import '../utils/context_ext.dart';
import 'video_actions.dart';
import 'video_card.dart';
import 'video_thumbnail.dart';

/// Linha compacta: miniatura à esquerda e texto à direita
/// (lista "A seguir", histórico, playlists, busca).
class VideoListTile extends ConsumerWidget {
  const VideoListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.thumbWidth = 168,
    this.selected = false,
    this.leading,
    this.trailing,
    this.extraActions = const [],
  });

  final VideoItem item;
  final VoidCallback onTap;
  final double thumbWidth;
  final bool selected;
  final Widget? leading;
  final Widget? trailing;
  final List<ExtraVideoAction> extraActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void menu([Offset? pos]) => VideoActions.show(context, ref, item,
        globalPosition: pos, extra: extraActions);

    return Semantics(
      button: true,
      selected: selected,
      label: item.title,
      child: GestureDetector(
        onSecondaryTapUp: (d) => menu(d.globalPosition),
        onLongPress: menu,
        child: Material(
          color: selected
              ? context.colors.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ?leading,
                  SizedBox(
                    width: thumbWidth,
                    child: VideoThumbnail(item: item, radius: 8, cacheWidth: 336),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          videoMetaLine(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing ??
                      IconButton(
                        tooltip: context.l10n.actionMenu,
                        icon: const Icon(Icons.more_vert, size: 20),
                        visualDensity: VisualDensity.compact,
                        onPressed: menu,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
