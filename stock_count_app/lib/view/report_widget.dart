import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/item_model.dart';
import 'category_view.dart';

class ReportWidget extends StatelessWidget {
  final List<Item> checkedItems;
  final String title;
  final String? location;

  const ReportWidget({
    super.key,
    required this.checkedItems,
    this.title = 'Stock Count Report',
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yy').format(now);

    // Group items by category
    final groupedItems = <Category, List<Item>>{};
    for (final item in checkedItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // Split categories into columns (3 columns)
    final categories = groupedItems.keys.toList();
    final columnCount = 3;
    final columns = <List<Category>>[];

    for (int i = 0; i < columnCount; i++) {
      columns.add([]);
    }

    for (int i = 0; i < categories.length; i++) {
      columns[i % columnCount].add(categories[i]);
    }

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Multi-column category layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns.map((columnCategories) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: columnCategories.map((category) {
                        final items = groupedItems[category] ?? [];
                        return _buildCategoryColumn(category, items);
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer section
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location?.toUpperCase() ?? title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'COUNT BY: ______________',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DATE: $dateStr',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
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

  Widget _buildCategoryColumn(Category category, List<Item> items) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with yellow background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Items list
          ...items.map((item) {
            String statusMarker = '';
            Color markerColor = Colors.black;

            if (item.status == ItemStatus.low) {
              statusMarker = 'LOW';
              markerColor = Colors.red;
            } else if (item.status == ItemStatus.zero) {
              statusMarker = 'O';
              markerColor = Colors.red;
            } else if (item.status == ItemStatus.urgent) {
              statusMarker = '!';
              markerColor = Colors.red;
            } else if (item.status == ItemStatus.pieces) {
              statusMarker = item.pieces.toString();
              markerColor = Colors.red;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Status indicator or checkbox
                  if (statusMarker.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: markerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        statusMarker,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: markerColor,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.circle, size: 12, color: Colors.black),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
