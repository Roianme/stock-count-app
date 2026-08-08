import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_count_app/data/item_data.dart';
import 'package:stock_count_app/data/platform_item_repository.dart';
import 'package:stock_count_app/model/category_model.dart';
import 'package:stock_count_app/model/item_model.dart';
import 'package:stock_count_app/services/backup_service.dart';

/// Integration tests for the persistence fix:
/// Verifying that deleted seed items stay deleted across app restarts,
/// and that resetDeletedSeedItems restores them.
void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create a unique temp directory for each test to avoid cross-contamination.
    tempDir = Directory.systemTemp.createTempSync('stock_count_test_');

    // Mock path_provider so Hive.initFlutter() uses our temp dir.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );

    // Register Hive adapters (same as production).
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ModeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ItemUnitOptionRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CategoryRecordAdapter());
    }

    // Capture seed data before repository uses it.
    initializeSeedData();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  /// Helper: create a fresh repository and load items (simulates app startup).
  Future<List<Item>> startAppAndLoadItems() async {
    final repo = PlatformItemRepository();
    await repo.initialize();
    final loaded = await repo.loadItems();
    await repo.close();
    return loaded;
  }

  /// Helper: reset the global items list to the original seed data.
  /// In production, main.dart does this once at startup. Our tests
  /// create multiple repository instances sequentially, so we must
  /// reset items to ensure upsert logic sees the full seed.
  void resetItemsToSeed() {
    items
      ..clear()
      ..addAll(seedItemsById.values.map((i) => i.copyWith()));
  }

  group('Persistence: deleted seed items', () {

    test('should NOT re-add a deleted seed item on next app start', () async {
      // 1. First start: items include all seed data.
      final firstLoad = await startAppAndLoadItems();
      expect(firstLoad.any((i) => i.id == 5), isTrue,
          reason: 'Seed item id=5 should exist on first launch');

      // 2. Delete item id=5.
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 5);
        await repo.saveItems(items);
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start (simulate app restart).
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == 5), isFalse,
          reason: 'Deleted seed item id=5 should NOT reappear after restart');
    });

    test('should re-add deleted seed item after resetDeletedSeedItems', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Delete item id=5 and then reset tracking.
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 5);
        await repo.saveItems(items);
        await repo.resetDeletedSeedItems();
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: item id=5 should be re-added.
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == 5), isTrue,
          reason: 'Seed item id=5 should be restored after reset');
    });

    test('should persist a user-created item across restarts', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Add a new custom item.
      final int newItemId;
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        final newItem = Item(
          name: 'Test Persistence Item',
          category: Category.misc,
          categoryId: categoryRecordIdFor(Category.misc),
        );
        newItemId = newItem.id;
        items.add(newItem);
        await repo.saveItems(items);
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: custom item should persist.
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == newItemId), isTrue,
          reason: 'User-created item should persist across restarts');
    });

    test('should persist item modifications across restarts', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Modify item id=1 name.
      const newName = 'MODIFIED pork skewers';
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        final idx = items.indexWhere((i) => i.id == 1);
        expect(idx, isNot(-1));
        items[idx] = items[idx].copyWith(name: newName);
        await repo.saveItems(items);
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: modification should persist.
      final secondLoad = await startAppAndLoadItems();
      final modified = secondLoad.firstWhere((i) => i.id == 1);
      expect(modified.name, equals(newName),
          reason: 'Modified item name should persist across restarts');
    });

    test('should NOT re-add multiple deleted seed items', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Delete items id=1 and id=2.
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 1 || i.id == 2);
        await repo.saveItems(items);
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: neither should appear.
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == 1), isFalse);
      expect(secondLoad.any((i) => i.id == 2), isFalse);
      expect(secondLoad.any((i) => i.id == 3), isTrue,
          reason: 'Non-deleted seed items should still be present');
    });

    test('should restore ALL seed items after deleteAll + reload', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Delete some items, then call deleteAll.
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 1);
        await repo.saveItems(items);
        await repo.deleteAll(); // This also clears deleted seed IDs.
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: all seed items should be back (deleteAll resets).
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == 1), isTrue,
          reason: 'After deleteAll, all seed items should be restored');
    });
  });

  group('ID remapping migration (v3→v4)', () {
    test('user-created items get IDs >= 10000 on fresh creation', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Create a new item without explicit ID.
      final int newItemId;
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        final newItem = Item(
          name: 'ID Range Test Item',
          category: Category.misc,
          categoryId: categoryRecordIdFor(Category.misc),
        );
        newItemId = newItem.id;
        items.add(newItem);
        await repo.saveItems(items);
        await repo.close();
      }

      expect(newItemId, greaterThanOrEqualTo(10000),
          reason: 'New user-created items should start at ID 10000');
    });

    test('should remap legacy user items from <10000 to 10000+', () async {
      // 1. First start: seed the repository.
      await startAppAndLoadItems();

      // 2. Directly insert a "legacy" user item with old-style ID (e.g., 500)
      //    into Hive, and set data version to 3 so migration v4 fires.
      const legacyId = 500;
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        final legacyItem = Item(
          id: legacyId,
          name: 'Legacy User Item (should be remapped)',
          category: Category.misc,
          categoryId: categoryRecordIdFor(Category.misc),
        );
        items.add(legacyItem);
        await repo.saveItems(items);
        // Set stored version to 3 to force migration v4 on next load.
        await repo.setDataVersionForTest(3);
        await repo.close();
      }

      // Reset global items to seed before simulating restart.
      resetItemsToSeed();

      // 3. Second start: migration v4 should remap the legacy item.
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == legacyId), isFalse,
          reason: 'Legacy ID $legacyId should be gone after migration');
      expect(secondLoad.any((i) => i.name == 'Legacy User Item (should be remapped)'), isTrue,
          reason: 'Legacy item should exist but with a new ID');
      final remapped = secondLoad.firstWhere(
        (i) => i.name == 'Legacy User Item (should be remapped)',
      );
      expect(remapped.id, greaterThanOrEqualTo(10000),
          reason: 'Remapped ID should be >= 10000, got ${remapped.id}');
    });

    test('seed items retain original IDs after v4 migration', () async {
      // 1. First start.
      await startAppAndLoadItems();

      // 2. Set version to 3, insert a legacy user item, and save.
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        final legacyItem = Item(
          id: 600,
          name: 'Another Legacy Item',
          category: Category.misc,
          categoryId: categoryRecordIdFor(Category.misc),
        );
        items.add(legacyItem);
        await repo.saveItems(items);
        await repo.setDataVersionForTest(3);
        await repo.close();
      }

      resetItemsToSeed();

      // 3. Second start: migration runs. Seed items keep their IDs.
      final secondLoad = await startAppAndLoadItems();
      expect(secondLoad.any((i) => i.id == 1), isTrue,
          reason: 'Seed item id=1 should keep its original ID');
      expect(secondLoad.any((i) => i.id == 5), isTrue,
          reason: 'Seed item id=5 should keep its original ID');
      expect(secondLoad.any((i) => i.id == 600), isFalse,
          reason: 'Legacy user item with id=600 should be remapped');
    });
  });

  group('Stress tests', () {
    test('T1: delete 5 seed items → all stay deleted after restart', () async {
      await startAppAndLoadItems();
      const deletedIds = {3, 7, 12, 25, 50};
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => deletedIds.contains(i.id));
        await repo.saveItems(items);
        await repo.close();
      }
      resetItemsToSeed();
      final secondLoad = await startAppAndLoadItems();
      for (final id in deletedIds) {
        expect(secondLoad.any((i) => i.id == id), isFalse,
            reason: 'Deleted seed item id=$id should stay deleted');
      }
      expect(secondLoad.any((i) => i.id == 1), isTrue);
      expect(secondLoad.any((i) => i.id == 10), isTrue);
    });

    test('T3: add 20 custom items → all persist with IDs ≥ 10000', () async {
      await startAppAndLoadItems();
      final customIds = <int>[];
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        for (int j = 0; j < 20; j++) {
          final item = Item(
            name: 'Stress Item $j',
            category: Category.misc,
            categoryId: categoryRecordIdFor(Category.misc),
          );
          customIds.add(item.id);
          items.add(item);
        }
        await repo.saveItems(items);
        await repo.close();
      }
      for (final id in customIds) {
        expect(id, greaterThanOrEqualTo(10000),
            reason: 'Custom item id=$id should be ≥ 10000');
      }
      resetItemsToSeed();
      final secondLoad = await startAppAndLoadItems();
      for (final id in customIds) {
        expect(secondLoad.any((i) => i.id == id), isTrue,
            reason: 'Custom item id=$id should persist');
      }
    });

    test('T6: restore with invalid JSON throws FormatException', () {
      expect(
        () => BackupService.importFromJson('{broken'),
        throwsA(isA<FormatException>()),
      );
    });

    test('T8: rapid delete-backup-deleteMore-restore cycle', () async {
      await startAppAndLoadItems();

      String? backupJson;
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 5);
        await repo.saveItems(items);
        backupJson = await repo.exportBackup();
        await repo.close();
      }

      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.removeWhere((i) => i.id == 10);
        await repo.saveItems(items);
        await repo.close();
      }

      final backup = BackupService.importFromJson(backupJson!);
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.restoreBackup(
            backup.items, backup.categories, backup.metadata);
        await repo.close();
      }

      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        final loaded = await repo.loadItems();
        await repo.close();
        expect(loaded.any((i) => i.id == 5), isFalse,
            reason: 'Item 5 deleted before backup');
        expect(loaded.any((i) => i.id == 10), isTrue,
            reason: 'Item 10 was in backup — should return');
      }
    });

    test('T13: export → import → re-export is idempotent', () async {
      await startAppAndLoadItems();

      final List<Item> originalItems;
      final List<CategoryRecord> originalCategories;
      final meta = <String, dynamic>{
        'data_version': 4, 'deleted_seed_ids': <int>[5],
      };
      {
        final repo = PlatformItemRepository();
        await repo.initialize();
        await repo.loadItems();
        items.add(Item(name: 'Export Cycle Item', category: Category.misc,
            categoryId: categoryRecordIdFor(Category.misc)));
        await repo.saveItems(items);
        originalItems = List.from(items);
        originalCategories = List.from(categories);
        await repo.close();
      }

      final e1 = BackupService.exportToJson(
        items: originalItems, categories: originalCategories,
        metadata: meta,
      );
      final p = BackupService.importFromJson(e1);
      final e2 = BackupService.exportToJson(
        items: p.items, categories: p.categories, metadata: p.metadata,
      );

      final m1 = jsonDecode(e1) as Map<String, dynamic>..remove('exportedAt');
      final m2 = jsonDecode(e2) as Map<String, dynamic>..remove('exportedAt');
      expect(m1, equals(m2),
          reason: 'Export → Import → Export should be idempotent');
    });
  });
}