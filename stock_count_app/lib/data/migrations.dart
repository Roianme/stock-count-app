import 'package:flutter/foundation.dart';
import '../model/item_model.dart';
import '../model/category_model.dart';
import 'item_data.dart';

class DataMigrations {
  static const int CURRENT_VERSION = 3;

  /// Migration history:
  /// v1: Initial seed data
  /// v2: Removed spring roll wrap, puto bumbong, curly fries (dessert), squid ball, fish ball, kikiam
  /// v3: Backfill categoryId and unitOptions
  static Future<List<Item>> migrateData(
    List<Item> currentItems,
    int fromVersion,
  ) async {
    List<Item> items = List.from(currentItems);

    // v1 → v2 migration: Remove deprecated dessert items
    if (fromVersion < 2) {
      debugPrint('🔄 Migrating data from v1 to v2...');

      const deprecatedIds = {136, 138, 139, 140, 141, 142};
      final removedCount = items.length;

      items.removeWhere((item) => deprecatedIds.contains(item.id));

      final newCount = items.length;
      debugPrint(
        '✅ Migration v2 completed. Removed ${removedCount - newCount} items. '
        'Items: $removedCount → $newCount',
      );
    }

    // v2 → v3 migration: Backfill categoryId and unitOptions
    if (fromVersion < 3) {
      debugPrint('🔄 Migrating data from v2 to v3...');
      int categoryIdBackfilled = 0;
      int unitOptionsBackfilled = 0;

      for (int i = 0; i < items.length; i++) {
        var item = items[i];
        String? newCategoryId = item.categoryId;
        List<ItemUnitOptionRecord>? newUnitOptions;
        bool needsUpdate = false;

        if (newCategoryId == null) {
          newCategoryId = categoryRecordIdFor(item.category);
          categoryIdBackfilled++;
          needsUpdate = true;
        }

        if (item.unitOptions.isEmpty) {
          final legacyOptions = itemUnitOptionsById[item.id];
          if (legacyOptions != null && legacyOptions.isNotEmpty) {
            newUnitOptions = legacyOptions
                .map((opt) => ItemUnitOptionRecord(
                      label: opt.label,
                      isUrgent: opt.isUrgent,
                    ))
                .toList();
            unitOptionsBackfilled++;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          items[i] = item.copyWith(
            categoryId: newCategoryId,
            unitOptions: newUnitOptions ?? item.unitOptions,
          );
        }
      }

      debugPrint(
        '✅ Migration v3 completed. '
        'Backfilled categoryId for $categoryIdBackfilled items. '
        'Backfilled unitOptions for $unitOptionsBackfilled items.',
      );
    }

    return items;
  }
}
