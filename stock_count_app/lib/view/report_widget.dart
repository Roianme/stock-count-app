import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/item_model.dart';
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
        // Build columns with a specific ordering:
        // - Move FILIPINO SUPPLIER to where MISC was (3rd column, middle)
        // - Place MISC under CHEMICALS (4th column bottom)
        final columns = List.generate(4, (_) => <Category>[]);

        void addIfPresent(Category c, int col) {
          if (groupedItems.containsKey(c)) columns[col].add(c);
        }

        // Desired per-column order
        // Column 0
        addIfPresent(Category.bbqGrill, 0);
        addIfPresent(Category.spices, 0);
        addIfPresent(Category.colesWoolies, 0);
        // Column 1
        addIfPresent(Category.rawItems, 1);
        addIfPresent(Category.drinks, 1);
        addIfPresent(Category.produce, 1);
        // Column 2
        addIfPresent(Category.warehouse, 2);
        addIfPresent(Category.filipinoSupplier, 2);
        // Column 3
        addIfPresent(Category.essentials, 3);
        addIfPresent(Category.supplier, 3);
        addIfPresent(Category.chemicals, 3);
        addIfPresent(Category.misc, 3);

        // Fallback: place any remaining categories not yet placed
        final placed = columns.expand((c) => c).toSet();
        if (placed.length != categories.length) {
          int idx = 0;
          for (final c in categories) {
            if (!placed.contains(c)) {
              columns[idx % 4].add(c);
              idx++;
            }
          }
        }

        return Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${(location ?? title).toUpperCase()} | $dateStr',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'COUNT BY: ${name ?? 'Not provided'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryColumn(Category category, List<Item> items) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
              final isUnchecked = !item.isChecked;
              String statusMarker = 'OK';
              Color markerColor = Colors.greenAccent;

              if (isUnchecked) {
                statusMarker = '';
                markerColor = Colors.grey;
              } else if (item.status == ItemStatus.low) {
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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.2,
                          color: isUnchecked ? Colors.black45 : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 70),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
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
                                )
                              : null,
                        ),
                        child: Text(
                          statusMarker,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnchecked ? Colors.grey : markerColor,
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
