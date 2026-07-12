import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/item_model.dart';
import '../model/category_model.dart';
import 'item_data.dart';
import 'item_repository.dart';
import 'migrations.dart';

/// Platform-aware repository.
///
/// Uses Hive on all platforms:
/// - Mobile/Desktop: file-backed Hive.
/// - Web: IndexedDB-backed Hive.
///
/// Also performs a one-time migration to remove the legacy SharedPreferences
/// JSON blob (`sharedPrefsKey`) to prevent wasting localStorage space.
class PlatformItemRepository implements ItemRepository {
  static const String boxName = 'items_box';
  static const String sharedPrefsKey = 'stock_count_items';

  late Box<Item> _hiveBox;
  late Box<CategoryRecord> _categoriesBox;
  late Box _metaBox;
  bool _closed = false;

  /// Initialize based on platform
  Future<void> initialize() async {
    // Works on all platforms (web uses IndexedDB under the hood).
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ModeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ItemUnitOptionRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CategoryRecordAdapter());
    }

    _categoriesBox = await Hive.openBox<CategoryRecord>('categories_box');
    await ensureDefaultCategoriesSeeded(_categoriesBox);
    _metaBox = await Hive.openBox('meta_box');

    _hiveBox = await Hive.openBox<Item>(boxName);

    if (kIsWeb) {
      await _migrateAndCleanupLegacyWebStorage();
    }
  }

  @override
  Future<List<Item>> loadItems() async {
    return _loadItemsHive();
  }

  @override
  Future<List<CategoryRecord>> loadCategories() async {
    final categoriesList = _categoriesBox.values.toList();
    categoriesList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    
    categories
      ..clear()
      ..addAll(categoriesList);
      
    return categories;
  }

  @override
  Future<void> saveCategories(List<CategoryRecord> categoriesToSave) async {
    final desired = <String, CategoryRecord>{for (final cat in categoriesToSave) cat.id: cat};
    final existingKeys = _categoriesBox.keys.whereType<String>().toSet();
    final desiredKeys = desired.keys.toSet();
    final keysToDelete = existingKeys.difference(desiredKeys);
    if (keysToDelete.isNotEmpty) {
      await _categoriesBox.deleteAll(keysToDelete);
    }
    await _categoriesBox.putAll(desired);
  }

  @override
  Future<void> addCategory(CategoryRecord category) async {
    if (categories.any((c) => c.id == category.id)) {
      throw StateError(
        'Category with id "${category.id}" already exists. '
        'Use updateCategory() to modify an existing category.',
      );
    }
    categories.add(category);
    await saveCategories(categories);
  }

  @override
  Future<void> updateCategory(CategoryRecord category) async {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await saveCategories(categories);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    categories.removeWhere((c) => c.id == id);
    await saveCategories(categories);
  }

  @override
  bool isCategoryInUse(String categoryId) {
    return items.any((item) => item.categoryId == categoryId);
  }

  Future<List<Item>> _loadItemsHive() async {
    if (_hiveBox.isEmpty) {
      // First run: load seed data and save
      final seedItems = List<Item>.from(items);
      await saveItems(seedItems);
      await _setStoredDataVersion(DataMigrations.CURRENT_VERSION);
      return seedItems;
    }
    
    var loadedItems = _hiveBox.values.toList();
    
    final storedVersion = await _getStoredDataVersion();
    if (storedVersion < DataMigrations.CURRENT_VERSION) {
      loadedItems = await DataMigrations.migrateData(loadedItems, storedVersion);
      await saveItems(loadedItems);
      await _setStoredDataVersion(DataMigrations.CURRENT_VERSION);
    }
    
    // Upsert: add any new seed items that don't exist in the box yet
    final existingIds = loadedItems.map((e) => e.id).toSet();
    final newItems = items
        .where((item) => !existingIds.contains(item.id))
        .toList();
    if (newItems.isNotEmpty) {
      loadedItems.addAll(newItems);
      await saveItems(loadedItems);
    }
    
    return loadedItems;
  }

  @override
  Future<void> saveItems(List<Item> itemsToSave) async {
    try {
      await _saveItemsHive(itemsToSave);
    } catch (e) {
      debugPrint('Error saving items: $e');
      rethrow;
    }
  }

  Future<void> _saveItemsHive(List<Item> itemsToSave) async {
    // Incremental write: avoids clearing the box (reduces IO/write amplification)
    // and helps prevent growth of stale records.
    final desired = <int, Item>{for (final item in itemsToSave) item.id: item};

    // Remove any keys that no longer exist (defensive; items are usually stable).
    final existingKeys = _hiveBox.keys.whereType<int>().toSet();
    final desiredKeys = desired.keys.toSet();
    final keysToDelete = existingKeys.difference(desiredKeys);
    if (keysToDelete.isNotEmpty) {
      await _hiveBox.deleteAll(keysToDelete);
    }

    await _hiveBox.putAll(desired);
  }

  @override
  Future<List<Item>> getCheckedItemsForExport() async {
    final allItems = await loadItems();
    return allItems.where((item) => item.isChecked).toList();
  }

  @override
  Future<void> clearAllChecked(List<Item> itemsList) async {
    try {
      final updated = itemsList.map((item) {
        return item.copyWith(isChecked: false);
      }).toList();
      await saveItems(updated);
    } catch (e) {
      debugPrint('Error clearing checked items: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasData() async {
    return _hiveBox.isNotEmpty;
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _hiveBox.clear();
      // Helps reclaim disk space in some environments.
      await _hiveBox.compact();

      if (kIsWeb) {
        // Ensure legacy blob is removed too.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(sharedPrefsKey);
      }
    } catch (e) {
      debugPrint('Error deleting all items: $e');
      rethrow;
    }
  }

  /// Close resources (call on app shutdown)
  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (_hiveBox.isOpen) {
      await _hiveBox.close();
    }
    if (_categoriesBox.isOpen) {
      await _categoriesBox.close();
    }
    if (_metaBox.isOpen) {
      await _metaBox.close();
    }
  }

  Future<void> _migrateAndCleanupLegacyWebStorage() async {
    // Legacy web storage was a single large JSON string in SharedPreferences.
    // Migrate once (only if Hive is empty), then remove the legacy key to free
    // up localStorage space.
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(sharedPrefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }

    if (_hiveBox.isEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final migrated = jsonList
            .map((json) => _itemFromJson(json as Map<String, dynamic>))
            .toList();
        await _saveItemsHive(migrated);
      } catch (e) {
        debugPrint('Legacy web storage migration failed: $e');
        // If migration fails, we keep the legacy key so the app can continue
        // to function (seed data fallback will still work).
        return;
      }
    }

    // Remove legacy blob regardless (either migrated or hive already had data).
    await prefs.remove(sharedPrefsKey);
  }

  Item _itemFromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      category: Category.values[json['category'] as int],
      status: ItemStatus.values[json['status'] as int],
      isChecked: json['isChecked'] as bool,
      quantity: json['quantity'] as int?,
    );
  }

  Future<int> _getStoredDataVersion() async {
    try {
      final version = _metaBox.get('data_version', defaultValue: 1);
      return version as int;
    } catch (e) {
      debugPrint('Error reading data version: $e');
      return 1;
    }
  }

  Future<void> _setStoredDataVersion(int version) async {
    try {
      await _metaBox.put('data_version', version);
    } catch (e) {
      debugPrint('Error storing data version: $e');
    }
  }
}
