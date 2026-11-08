import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_item.dart';
import '../utils/context_ext.dart';
import '../utils/formatters.dart';
import 'video_actions.dart';
import 'video_thumbnail.dart';

/// Linha de metadados: `pasta • 1,2 GB • 1080p • há 3 dias`.
String videoMetaLine(VideoItem item, {bool includeFolder = true}) {
  final v = item.video;
  return [
    if (includeFolder) item.folderName,
    Fmt.fileSize(v.sizeBytes),
    ?Fmt.resolution(v.width, v.height),
    Fmt.relative(v.modifiedAt),
  ].join(' • ');
}

/// Avatar circular com a inicial da pasta ("avatar do canal").
class FolderAvatar extends StatelessWidget {
  const FolderAvatar({super.key, required this.name, this.radius = 18});

  final String name;
  final double radius;

  static const _palette = [
    Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00), Color(0xFF8E24AA),
    Color(0xFF43A047), Color(0xFF1E88E5), Color(0xFFD81B60), Color(0xFF6D4C41),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
    final color = _palette[name.hashCode.abs() % _palette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}

/// Card de vídeo da grade (estilo "página inicial").
class VideoCard extends ConsumerStatefulWidget {
  const VideoCard({
    super.key,
    required this.item,
    required this.onTap,
    this.showFolder = true,
    this.extraActions = const [],
  });

  final VideoItem item;
  final VoidCallback onTap;
  final bool showFolder;
  final List<ExtraVideoAction> extraActions;

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard> {
  bool _hover = false;

  void _menu([Offset? position]) => VideoActions.show(
        context,
        ref,
        widget.item,
        globalPosition: position,
        extra: widget.extraActions,
      );

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Semantics(
      button: true,
      label: '${item.title}, ${videoMetaLine(item)}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onSecondaryTapUp: (d) => _menu(d.globalPosition),
          onLongPress: _menu,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _hover
                    ? context.colors.surfaceContainerHigh.withValues(alpha: 0.6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedScale(
                    scale: _hover ? 1.02 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: VideoThumbnail(item: item),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showFolder) ...[
                        FolderAvatar(name: item.folderName),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall?.copyWith(
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              videoMetaLine(item, includeFolder: widget.showFolder),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MenuButton(onPressed: () => _menu()),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => IconButton(
        tooltip: context.l10n.actionMenu,
        icon: const Icon(Icons.more_vert, size: 20),
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: onPressed,
      ),
    );
  }
}
