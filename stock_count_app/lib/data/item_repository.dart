import '../model/item_model.dart';
import '../model/category_model.dart';

abstract class ItemRepository {
  /// Load all categories from storage, sorted by sortOrder
  Future<List<CategoryRecord>> loadCategories();

  /// Save all categories to storage
  Future<void> saveCategories(List<CategoryRecord> categories);

  /// Add a new category
  Future<void> addCategory(CategoryRecord category);

  /// Update an existing category
  Future<void> updateCategory(CategoryRecord category);

  /// Delete a category by id
  Future<void> deleteCategory(String id);

  /// Check if a category is used by any item
  bool isCategoryInUse(String categoryId);
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
