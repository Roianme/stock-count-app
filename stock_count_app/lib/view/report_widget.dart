import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/item_model.dart';
import 'category_view.dart';

class ReportWidget extends StatelessWidget {
  final List<Item> checkedItems;
  final String title;
  final String? location;
  final String? name;

  const ReportWidget({
    super.key,
    required this.checkedItems,
    this.title = 'Stock Count Report',
    this.location,
    this.name,
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
    final categories = groupedItems.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _columnCountForWidth(constraints.maxWidth);
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
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
                        'COUNT BY: $name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DATE: $dateStr',
                        style: TextStyle(
                          fontSize: 20,
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
      },
    );
  }

  int _columnCountForWidth(double width) {
    // Use responsive helper breakpoints for consistency
    if (width >= 1400) return 4;
    if (width >= 1024) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  Widget _buildCategoryColumn(Category category, List<Item> items) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                category.displayName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...items.map((item) {
              String statusMarker = 'OK';
              Color markerColor = Colors.greenAccent;

              if (item.status == ItemStatus.low) {
                statusMarker = 'LOW';
                markerColor = Colors.orangeAccent;
              } else if (item.status == ItemStatus.zero) {
                statusMarker = 'O';
                markerColor = Colors.black;
              } else if (item.status == ItemStatus.urgent) {
                statusMarker = 'URGENT';
                markerColor = Colors.redAccent;
              } else if (item.status == ItemStatus.pieces) {
                statusMarker = item.pieces.toString();
                markerColor = Colors.blueAccent;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (statusMarker.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: markerColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          statusMarker,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: markerColor,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.circle, size: 20, color: Colors.black),
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
