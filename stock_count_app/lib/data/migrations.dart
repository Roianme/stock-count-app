import 'package:flutter/foundation.dart';
import '../model/item_model.dart';
import '../model/category_model.dart';
import 'item_data.dart';

class DataMigrations {
  static const int CURRENT_VERSION = 4;

  /// Migration history:
  /// v1: Initial seed data
  /// v2: Removed spring roll wrap, puto bumbong, curly fries (dessert), squid ball, fish ball, kikiam
  /// v3: Backfill categoryId and unitOptions
  /// v4: Remap user-created item IDs to 10000+ range (avoids collision with future seed items)
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

    // v3 → v4 migration: Remap user-created item IDs to 10000+ range.
    // Seed items retain their original IDs (1-9999). User-created items
    // get reassigned IDs starting at 10000 to prevent collisions with
    // future seed items added in code updates.
    if (fromVersion < 4) {
      debugPrint('🔄 Migrating data from v3 to v4 (ID remapping)...');
      int nextUserIndex = 10000;
      int remappedCount = 0;

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        if (!seedItemsById.containsKey(item.id) && item.id < 10000) {
          items[i] = item.copyWith(id: nextUserIndex++);
          remappedCount++;
        }
      }

      debugPrint(
        '✅ Migration v4 completed. Remapped $remappedCount user items '
        'to 10000+ ID range.',
      );
    }

    return items;
  }
}
