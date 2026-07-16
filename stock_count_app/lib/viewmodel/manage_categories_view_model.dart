import 'package:flutter/foundation.dart';
import '../model/category_model.dart';
import '../data/item_data.dart' as data;
import '../data/item_repository.dart';

class ManageCategoriesViewModel extends ChangeNotifier {
  final ItemRepository repository;

  ManageCategoriesViewModel({required this.repository}) {
    _loadCategories();
  }

  List<CategoryRecord> _categories = [];

  List<CategoryRecord> get categories => List.unmodifiable(_categories);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  void _loadCategories() {
    final sorted = List<CategoryRecord>.from(data.categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _categories = sorted;
    notifyListeners();
  }

  /// Generate a stable unique id from a display name
  String _generateId(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final base = slug.isEmpty ? 'category' : slug;
    // Ensure uniqueness by appending a suffix if needed
    String id = base;
    int counter = 1;
    while (data.categories.any((c) => c.id == id)) {
      id = '$base$counter';
      counter++;
    }
    return id;
  }

  Future<bool> addCategory({
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    _errorMessage = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Category name cannot be empty';
      notifyListeners();
      return false;
    }

    // Auto-assign next sort order
    final maxOrder = data.categories.isEmpty
        ? 0
        : data.categories.map((c) => c.sortOrder).reduce(
              (a, b) => a > b ? a : b,
            );
    final sortOrder = maxOrder + 1;

    final id = _generateId(trimmedName);

    final record = CategoryRecord(
      id: id,
      name: trimmedName,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      iconFontFamily: 'MaterialIcons',
      sortOrder: sortOrder,
    );

    try {
      await repository.addCategory(record);
      _loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    _errorMessage = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'Category name cannot be empty';
      notifyListeners();
      return false;
    }

    final existing = data.categories.firstWhere(
      (c) => c.id == id,
      orElse: () => throw StateError('Category "$id" not found'),
    );

    final updated = CategoryRecord(
      id: id,
      name: trimmedName,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      iconFontFamily: existing.iconFontFamily,
      sortOrder: existing.sortOrder,
    );

    try {
      await repository.updateCategory(updated);
      _loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  /// Returns the number of items using this category if >0, or 0 if safe to delete.
  int categoryItemCount(String categoryId) {
    return data.items.where((item) => item.categoryId == categoryId).length;
  }

  Future<bool> deleteCategory(String id) async {
    _errorMessage = null;

    final inUseCount = categoryItemCount(id);
    if (inUseCount > 0) {
      _errorMessage =
          'Cannot delete: $inUseCount item(s) are using this category';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    notifyListeners();

    try {
      await repository.deleteCategory(id);
      _loadCategories();
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
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
