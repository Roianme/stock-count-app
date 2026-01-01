import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../model/item_model.dart';
import 'item_data.dart';
import 'item_repository.dart';

class HiveItemRepository implements ItemRepository {
  static const String boxName = 'items_box';
  late Box<Item> _box;

  /// Initialize Hive and open the box
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ItemAdapter());
    }

    _box = await Hive.openBox<Item>(boxName);
  }

  @override
  Future<List<Item>> loadItems() async {
    if (_box.isEmpty) {
      // First run: load seed data and save
      final seedItems = List<Item>.from(items);
      await saveItems(seedItems);
      return seedItems;
    }
    return _box.values.toList();
  }

  @override
  Future<void> saveItems(List<Item> itemsToSave) async {
    try {
      await _box.clear();
      for (final item in itemsToSave) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint('Error saving items: $e');
      rethrow;
    }
  }

  @override
  Future<List<Item>> getCheckedItemsForExport() async {
    return _box.values.where((item) => item.isChecked).toList();
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
    return _box.isNotEmpty;
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _box.clear();
    } catch (e) {
      debugPrint('Error deleting all items: $e');
      rethrow;
    }
  }

  /// Close the box (call on app shutdown)
  Future<void> close() async {
    await _box.close();
  }
}
