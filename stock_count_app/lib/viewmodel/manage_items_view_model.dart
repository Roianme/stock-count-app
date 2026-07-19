import 'package:flutter/foundation.dart' hide Category;
import '../model/item_model.dart';
import '../model/category_model.dart';
import '../data/item_data.dart' as data;
import '../data/item_repository.dart';

class ManageItemsViewModel extends ChangeNotifier {
  final ItemRepository repository;

  ManageItemsViewModel({required this.repository}) {
    _load();
  }

  List<Item> _items = [];
  List<Item> get items => List.unmodifiable(_items);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  /// Group items by their resolved category for display.
  Map<CategoryRecord, List<Item>> get groupedItems {
    final map = <CategoryRecord, List<Item>>{};
    for (final item in _items) {
      final cat = data.categories.cast<CategoryRecord?>().firstWhere(
            (c) => c?.id == item.categoryId,
            orElse: () => null,
          );
      final key = cat ?? _fallbackRecordFor(item.category);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  List<CategoryRecord> get sortedCategories {
    return data.categories
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Fallback CategoryRecord for items whose categoryId doesn't match any live category.
  CategoryRecord _fallbackRecordFor(Category category) {
    return CategoryRecord(
      id: categoryRecordIdFor(category),
      name: category.displayName,
      colorValue: category.color.toARGB32(),
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
      sortOrder: 999,
    );
  }

  /// Determine the legacy Category enum for a given categoryId.
  /// Returns the matching enum value for original categories, or Category.misc for custom ones.
  Category _legacyCategoryFor(String? categoryId) {
    if (categoryId != null) {
      for (final cat in Category.values) {
        if (categoryRecordIdFor(cat) == categoryId) return cat;
      }
    }
    return Category.misc;
  }

  void _load() {
    _items = List<Item>.from(data.items);
    notifyListeners();
  }

  Future<bool> addItem({
    required String name,
    required String categoryId,
    required Set<Mode> modes,
    required List<ItemUnitOptionRecord> unitOptions,
  }) async {
    _errorMessage = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Item name cannot be empty';
      notifyListeners();
      return false;
    }

    final legacyCat = _legacyCategoryFor(categoryId);

    final item = Item(
      name: trimmedName,
      category: legacyCat,
      status: ItemStatus.quantity,
      modes: modes,
      unitOptions: unitOptions,
      categoryId: categoryId,
    );

    try {
      data.items.add(item);
      await repository.saveItems(data.items);
      _load();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem({
    required int itemId,
    required String name,
    required String categoryId,
    required Set<Mode> modes,
    required List<ItemUnitOptionRecord> unitOptions,
  }) async {
    _errorMessage = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Item name cannot be empty';
      notifyListeners();
      return false;
    }

    final index = data.items.indexWhere((i) => i.id == itemId);
    if (index == -1) {
      _errorMessage = 'Item not found';
      notifyListeners();
      return false;
    }

    final legacyCat = _legacyCategoryFor(categoryId);

    data.items[index] = data.items[index].copyWith(
      name: trimmedName,
      category: legacyCat,
      modes: modes,
      unitOptions: unitOptions,
      categoryId: categoryId,
    );

    try {
      await repository.saveItems(data.items);
      _load();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int itemId) async {
    _errorMessage = null;
    _isDeleting = true;
    notifyListeners();

    try {
      data.items.removeWhere((item) => item.id == itemId);
      await repository.saveItems(data.items);
      _load();
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
