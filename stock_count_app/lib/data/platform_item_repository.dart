import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/item_model.dart';
import 'item_data.dart';
import 'item_repository.dart';

/// Platform-aware repository that uses Hive on mobile and SharedPreferences on web
class PlatformItemRepository implements ItemRepository {
  static const String boxName = 'items_box';
  static const String sharedPrefsKey = 'stock_count_items';

  late Box<Item> _hiveBox;
  late SharedPreferences _sharedPrefs;

  /// Initialize based on platform
  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWeb();
    } else {
      await _initializeMobile();
    }
  }

  /// Initialize Hive for mobile platforms (Android, iOS, etc.)
  Future<void> _initializeMobile() async {
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

    _hiveBox = await Hive.openBox<Item>(boxName);
  }

  /// Initialize SharedPreferences for web
  Future<void> _initializeWeb() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Item>> loadItems() async {
    if (kIsWeb) {
      return _loadItemsWeb();
    } else {
      return _loadItemsMobile();
    }
  }

  Future<List<Item>> _loadItemsMobile() async {
    if (_hiveBox.isEmpty) {
      // First run: load seed data and save
      final seedItems = List<Item>.from(items);
      await saveItems(seedItems);
      return seedItems;
    }
    return _hiveBox.values.toList();
  }

  Future<List<Item>> _loadItemsWeb() async {
    final jsonString = _sharedPrefs.getString(sharedPrefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      // First run: load seed data and save
      final seedItems = List<Item>.from(items);
      await saveItems(seedItems);
      return seedItems;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => _itemFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading items from SharedPreferences: $e');
      // Fallback to seed data
      final seedItems = List<Item>.from(items);
      await saveItems(seedItems);
      return seedItems;
    }
  }

  @override
  Future<void> saveItems(List<Item> itemsToSave) async {
    try {
      if (kIsWeb) {
        await _saveItemsWeb(itemsToSave);
      } else {
        await _saveItemsMobile(itemsToSave);
      }
    } catch (e) {
      debugPrint('Error saving items: $e');
      rethrow;
    }
  }

  Future<void> _saveItemsMobile(List<Item> itemsToSave) async {
    await _hiveBox.clear();
    for (final item in itemsToSave) {
      await _hiveBox.put(item.id, item);
    }
  }

  Future<void> _saveItemsWeb(List<Item> itemsToSave) async {
    final jsonList = itemsToSave.map((item) => _itemToJson(item)).toList();
    final jsonString = jsonEncode(jsonList);
    await _sharedPrefs.setString(sharedPrefsKey, jsonString);
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
    if (kIsWeb) {
      return _sharedPrefs.getString(sharedPrefsKey) != null;
    } else {
      return _hiveBox.isNotEmpty;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      if (kIsWeb) {
        await _sharedPrefs.remove(sharedPrefsKey);
      } else {
        await _hiveBox.clear();
      }
    } catch (e) {
      debugPrint('Error deleting all items: $e');
      rethrow;
    }
  }

  /// Close resources (call on app shutdown)
  Future<void> close() async {
    if (!kIsWeb) {
      await _hiveBox.close();
    }
  }

  // JSON serialization helpers for web storage
  Map<String, dynamic> _itemToJson(Item item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category.index,
      'status': item.status.index,
      'isChecked': item.isChecked,
      'pieces': item.pieces,
    };
  }

  Item _itemFromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      category: Category.values[json['category'] as int],
      status: ItemStatus.values[json['status'] as int],
      isChecked: json['isChecked'] as bool,
      pieces: json['pieces'] as int,
    );
  }
}
