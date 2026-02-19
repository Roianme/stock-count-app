import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/item_model.dart';
import '../data/item_data.dart' as data;
import 'category_view.dart';

class ReportWidget extends StatelessWidget {
  final List<Item> items;
  final String title;
  final String? location;
  final String? name;

  const ReportWidget({
    super.key,
    required this.items,
    this.title = 'Stock Count Report',
    this.location,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(now);

    // Group items by category
    final groupedItems = <Category, List<Item>>{};
    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }
    final categories = groupedItems.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Height calculations for overflow awareness
        const headerHeight = 48.0;
        const topPadding = 12.0 + 8.0;
        const bottomPadding = 12.0;
        const categoryHeaderHeight = 18.0 + 3.0 * 2; // font + padding
        const itemHeight =
            19.0 * 1.2 + 4.0 * 2; // (fontSize * height) + vertical padding
        const chunkVerticalOverhead =
            10.0 * 2 + // container padding (all 10)
            8.0 * 2 + // inner padding (all 8)
            6.0 + // SizedBox after header
            4.0 * 2; // container margin vertical (symmetric vertical: 4)

        // Available height for categories (with conservative buffer)
        final availableHeight =
            constraints.maxHeight -
            headerHeight -
            topPadding -
            bottomPadding -
            40.0; // Minimal buffer for more usable vertical space

        const numColumns = 6; // Fixed number of columns

        // Build columns and chunks with proper overflow handling
        final columns = <List<CategoryChunk>>[];
        final categoryChunks = <CategoryChunk>[];

        for (final category in categories) {
          final itemList = groupedItems[category] ?? [];
          if (itemList.isEmpty) continue;

          // Calculate max items that fit in available height
          // Each category chunk needs: header + items + margins + padding
          final maxItemsPerChunk =
              ((availableHeight -
                          categoryHeaderHeight -
                          chunkVerticalOverhead) /
                      itemHeight)
                  .floor();

          // Use at least 2 items per chunk to ensure overflow works
          var itemsPerChunk = maxItemsPerChunk.clamp(2, 100);

          // Split category into chunks based on actual height available
          for (int i = 0; i < itemList.length; i += itemsPerChunk) {
            final endIdx = (i + itemsPerChunk).clamp(0, itemList.length);
            final chunk = itemList.sublist(i, endIdx);
            final estimatedHeight =
                categoryHeaderHeight +
                chunkVerticalOverhead +
                (chunk.length * itemHeight);
            categoryChunks.add(
              CategoryChunk(
                category: category,
                items: chunk,
                isFirstChunk: i == 0,
                estimatedHeight: estimatedHeight,
              ),
            );
          }
        }

        // Initialize columns
        for (int i = 0; i < numColumns; i++) {
          columns.add([]);
        }
        final columnHeights = List<double>.filled(numColumns, 0);

        // Sort chunks by height (largest first) for better bin packing
        final sortedChunks = List<CategoryChunk>.from(categoryChunks);
        sortedChunks.sort(
          (a, b) => b.estimatedHeight.compareTo(a.estimatedHeight),
        );

        // Distribute chunks using largest-first (better load balancing)
        for (final chunk in sortedChunks) {
          int targetColumn = 0;
          double minHeight = columnHeights[0];
          for (int i = 1; i < columnHeights.length; i++) {
            if (columnHeights[i] < minHeight) {
              minHeight = columnHeights[i];
              targetColumn = i;
            }
          }
          columns[targetColumn].add(chunk);
          columnHeights[targetColumn] += chunk.estimatedHeight;
        }

        return Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$location | $dateStr | BY: ${(name ?? 'Not provided').toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // Categories grid in landscape columns (ListView prevents overflow)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columns.map((colChunks) {
                      return Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: colChunks.map((chunk) {
                            final items = chunk.items;
                            final category = chunk.category;
                            final isFirstChunk = chunk.isFirstChunk;

                            return _buildCategoryColumn(
                              category,
                              items,
                              isFirstChunk: isFirstChunk,
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryColumn(
    Category category,
    List<Item> items, {
    bool isFirstChunk = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(10),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header - show even for continuation chunks
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                category.displayName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ...items.map((item) {
              final isUnchecked = !item.isChecked;
              final selectedUnit = data.selectedUnitOption(item);
              String statusMarker = 'OK';
              Color markerColor = Colors.greenAccent;

              if (isUnchecked) {
                statusMarker = '';
                markerColor = Colors.grey;
              } else if (selectedUnit != null) {
                if (selectedUnit.isUrgent) {
                  statusMarker = 'URGENT';
                  markerColor = Colors.redAccent;
                } else {
                  statusMarker = selectedUnit.label;
                  markerColor = Colors.green;
                }
              } else if (item.status == ItemStatus.urgent) {
                statusMarker = 'URGENT';
                markerColor = Colors.redAccent;
              } else if (item.status == ItemStatus.quantity) {
                statusMarker = item.quantity.toString();
                markerColor = Colors.blueAccent;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.3,
                          color: isUnchecked ? Colors.black38 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 70),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: markerColor.withValues(
                            alpha: isUnchecked ? 0.08 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: isUnchecked
                              ? Border.all(
                                  color: Colors.grey.withValues(alpha: 0.6),
                                  width: 0.5,
                                )
                              : null,
                        ),
                        child: Text(
                          statusMarker,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isUnchecked ? Colors.grey[600] : markerColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Helper class to represent a chunk of a category (for overflow handling)
class CategoryChunk {
  final Category category;
  final List<Item> items;
  final bool isFirstChunk;
  final double estimatedHeight;

  CategoryChunk({
    required this.category,
    required this.items,
    required this.isFirstChunk,
    required this.estimatedHeight,
  });
}
