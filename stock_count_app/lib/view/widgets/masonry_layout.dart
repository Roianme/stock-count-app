import 'package:flutter/material.dart';
import '../../model/item_model.dart';

/// Masonry layout that distributes items across 3 columns.
class MasonryLayout extends StatelessWidget {
  final List<Item> items;
  final double statusWidth;
  final Widget Function(Item) buildItemCard;

  const MasonryLayout({
    super.key,
    required this.items,
    required this.statusWidth,
    required this.buildItemCard,
  });

  @override
  Widget build(BuildContext context) {
    // Distribute items across 3 columns in a round-robin fashion.
    final columns = <List<Item>>[[], [], []];

    for (int i = 0; i < items.length; i++) {
      columns[i % 3].add(items[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int colIndex = 0; colIndex < 3; colIndex++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: colIndex == 0 ? 0 : 2,
                right: colIndex == 2 ? 0 : 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in columns[colIndex])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RepaintBoundary(
                        key: ValueKey(
                          'i-${item.id}-${item.status.name}-${item.quantity}-${item.isChecked}',
                        ),
                        child: buildItemCard(item),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
