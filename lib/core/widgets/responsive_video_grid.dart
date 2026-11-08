import 'package:flutter/material.dart';

import '../models/video_item.dart';
import 'video_card.dart';

/// Número de colunas conforme a largura disponível:
/// 1 coluna no celular, 2–5 em telas largas/janelas.
int gridColumnsFor(double width) {
  if (width < 600) return 1;
  return (width / 340).floor().clamp(2, 5);
}

/// Grade lazy de [VideoCard]s como sliver (rolagem fluida com milhares de itens).
class SliverVideoGrid extends StatelessWidget {
  const SliverVideoGrid({
    super.key,
    required this.videos,
    required this.onTap,
    this.showFolder = true,
  });

  final List<VideoItem> videos;
  final void Function(VideoItem item) onTap;
  final bool showFolder;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = gridColumnsFor(width);
        const spacing = 12.0;
        final horizontalPadding = columns == 1 ? 8.0 : 16.0;
        final itemWidth =
            (width - horizontalPadding * 2 - spacing * (columns - 1)) / columns;
        // Miniatura 16:9 + área de texto (título 2 linhas + metadados).
        final extent = (itemWidth - 8) * 9 / 16 + 112 * textScale;

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: columns == 1 ? 4 : spacing,
              mainAxisExtent: extent,
            ),
            itemCount: videos.length,
            itemBuilder: (context, i) => VideoCard(
              key: ValueKey(videos[i].id),
              item: videos[i],
              showFolder: showFolder,
              onTap: () => onTap(videos[i]),
            ),
          ),
        );
      },
    );
  }
}
