import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Um chip de filtro.
class FilterChipData<T> {
  const FilterChipData({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Linha de chips rolável horizontalmente (também com a roda do mouse).
class FilterChipsBar<T> extends StatefulWidget {
  const FilterChipsBar({
    super.key,
    required this.chips,
    required this.selected,
    required this.onSelected,
  });

  final List<FilterChipData<T>> chips;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  State<FilterChipsBar<T>> createState() => _FilterChipsBarState<T>();
}

class _FilterChipsBarState<T> extends State<FilterChipsBar<T>> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Listener(
        // Converte a roda vertical do mouse em rolagem horizontal.
        onPointerSignal: (e) {
          if (e is PointerScrollEvent && _scroll.hasClients) {
            final target = (_scroll.offset + e.scrollDelta.dy)
                .clamp(0.0, _scroll.position.maxScrollExtent);
            _scroll.jumpTo(target);
          }
        },
        child: ListView.separated(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: widget.chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final chip = widget.chips[i];
            final selected = chip.value == widget.selected;
            return ChoiceChip(
              label: Text(chip.label),
              avatar: chip.icon == null ? null : Icon(chip.icon, size: 16),
              selected: selected,
              onSelected: (_) => widget.onSelected(chip.value),
            );
          },
        ),
      ),
    );
  }
}
