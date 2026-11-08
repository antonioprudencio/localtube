import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/video_item.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';

/// Detalhes técnicos de um arquivo de vídeo.
class VideoInfoSheet extends StatelessWidget {
  const VideoInfoSheet({super.key, required this.item});

  final VideoItem item;

  static Future<void> show(BuildContext context, VideoItem item) {
    if (context.isWide) {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: VideoInfoSheet(item: item),
          ),
        ),
      );
    }
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => VideoInfoSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.title, style: context.text.titleMedium),
          const SizedBox(height: 12),
          VideoTechDetails(item: item),
        ],
      ),
    );
  }
}

/// Tabela de detalhes técnicos (também usada na tela Watch).
class VideoTechDetails extends StatelessWidget {
  const VideoTechDetails({super.key, required this.item});

  final VideoItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = item.video;
    final unknown = l.unknown;
    final rows = <(String, String)>[
      (l.infoPath, v.path),
      (l.infoFolder, item.folderName),
      (l.infoSize, Fmt.fileSize(v.sizeBytes)),
      (l.infoDuration, item.duration == null ? unknown : Fmt.duration(item.duration!)),
      (
        l.infoResolution,
        v.width == null
            ? unknown
            : '${v.width}×${v.height} (${Fmt.resolution(v.width, v.height)})',
      ),
      (l.infoVideoCodec, v.videoCodec ?? unknown),
      (l.infoAudioCodec, v.audioCodec ?? unknown),
      (l.infoContainer, v.container.toUpperCase()),
      (l.infoBitrate, Fmt.bitrate(v.sizeBytes, v.durationMs) ?? unknown),
      (l.infoModified, Fmt.dateTime(v.modifiedAt)),
    ];
    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    label,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onLongPress: () =>
                        Clipboard.setData(ClipboardData(text: value)),
                    child: SelectableText(value, style: context.text.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
