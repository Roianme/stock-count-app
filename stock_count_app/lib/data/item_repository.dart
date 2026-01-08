import '../model/item_model.dart';

abstract class ItemRepository {
  /// Load all items from storage
  Future<List<Item>> loadItems();

  /// Save all items to storage
  Future<void> saveItems(List<Item> items);

  /// Get all checked items ready for export
  Future<List<Item>> getCheckedItemsForExport();

  /// Clear checked status for all items
  Future<void> clearAllChecked(List<Item> items);

  /// Check if storage has data
  Future<bool> hasData();

  /// Delete all stored data
  Future<void> deleteAll();

  /// Close any resources (Hive boxes, etc.). Safe to call multiple times.
  Future<void> close();
}
