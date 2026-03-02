import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/item_model.dart';
import '../data/item_data.dart' as data;
import '../utils/index.dart';

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

    // Detect orientation and use appropriate layout
    final isLandscape = context.isLandscape;

    return isLandscape
        ? _buildLandscapeLayout(context, dateStr, categories, groupedItems)
        : _buildPortraitLayout(context, dateStr, categories, groupedItems);
  }

  /// Landscape layout: 6-column grid with smart chunking
  Widget _buildLandscapeLayout(
    BuildContext context,
    String dateStr,
    List<Category> categories,
    Map<Category, List<Item>> groupedItems,
  ) {
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

  /// Portrait layout: 2-column layout with categories distributed
  Widget _buildPortraitLayout(
    BuildContext context,
    String dateStr,
    List<Category> categories,
    Map<Category, List<Item>> groupedItems,
  ) {
    // Distribute categories across 2 columns (alternating)
    final leftColumnCategories = <Category>[];
    final rightColumnCategories = <Category>[];
    Category? dessertCategory;
    bool dessertInLeft = false;

    for (int i = 0; i < categories.length; i++) {
      if (categories[i] == Category.dessert) {
        dessertCategory = categories[i];
        dessertInLeft = (i % 2 == 0);
        leftColumnCategories.add(categories[i]);
      } else if (i % 2 == 0) {
        leftColumnCategories.add(categories[i]);
      } else {
        rightColumnCategories.add(categories[i]);
      }
    }

    // If dessert is in left column and has multiple items, add Part 2 to right column
    if (dessertCategory != null &&
        dessertInLeft &&
        (groupedItems[dessertCategory]?.length ?? 0) > 1) {
      rightColumnCategories.insert(0, dessertCategory);
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$location | $dateStr | BY: ${(name ?? 'Not provided').toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Categories in 2-column layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: leftColumnCategories.length,
                        itemBuilder: (context, index) {
                          final category = leftColumnCategories[index];
                          final categoryItems = groupedItems[category] ?? [];
                          return _buildPortraitCategorySection(
                            category,
                            categoryItems,
                            isLeftColumn: true,
                            contextCategory: category,
                          );
                        },
                      ),
                    ),
                  ),
                  // Right column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: rightColumnCategories.length,
                        itemBuilder: (context, index) {
                          final category = rightColumnCategories[index];
                          final categoryItems = groupedItems[category] ?? [];
                          return _buildPortraitCategorySection(
                            category,
                            categoryItems,
                            isLeftColumn: false,
                            isDessertPart2: category == Category.dessert,
                            contextCategory: category,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a category section for portrait mode
  Widget _buildPortraitCategorySection(
    Category category,
    List<Item> categoryItems, {
    required bool isLeftColumn,
    bool isDessertPart2 = false,
    required Category contextCategory,
  }) {
    // Split dessert category in half
    if (category == Category.dessert && categoryItems.length > 1) {
      final midpoint = (categoryItems.length / 2).ceil();
      final firstHalf = categoryItems.sublist(0, midpoint);
      final secondHalf = categoryItems.sublist(midpoint);

      // If in right column (part 2), show only second half
      if (isDessertPart2 && !isLeftColumn) {
        return _buildCategorySectionContent(
          category,
          secondHalf,
          isFirstHalf: false,
          isDessertPart2: true,
        );
      }

      // If in left column, show only first half
      if (isLeftColumn) {
        return _buildCategorySectionContent(
          category,
          firstHalf,
          isFirstHalf: true,
          isDessertPart2: false,
        );
      }
    }

    // Regular category display
    return _buildCategorySectionContent(category, categoryItems);
  }

  /// Build category section content
  Widget _buildCategorySectionContent(
    Category category,
    List<Item> categoryItems, {
    bool isFirstHalf = false,
    bool isDessertPart2 = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.displayName.toUpperCase() +
                    (isDessertPart2
                        ? ' (Part 2)'
                        : isFirstHalf && category == Category.dessert
                        ? ' (Part 1)'
                        : ''),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Items in 3-column masonry layout
          _buildPortraitMasonry(categoryItems),
        ],
      ),
    );
  }

  /// Build masonry layout for portrait mode items
  Widget _buildPortraitMasonry(List<Item> items) {
    // Distribute items across 3 columns
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
                left: colIndex == 0 ? 0 : 4,
                right: colIndex == 2 ? 0 : 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in columns[colIndex])
                    _buildPortraitItemCard(item),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Build individual item card for portrait mode
  Widget _buildPortraitItemCard(Item item) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 18,
                height: 1.2,
                color: isUnchecked ? Colors.black38 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: markerColor.withValues(alpha: isUnchecked ? 0.08 : 0.2),
              borderRadius: BorderRadius.circular(4),
              border: isUnchecked
                  ? Border.all(
                      color: Colors.grey.withValues(alpha: 0.6),
                      width: 1,
                    )
                  : null,
            ),
            child: Text(
              statusMarker,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isUnchecked ? Colors.grey[600] : markerColor,
              ),
            ),
          ),
        ],
      ),
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
