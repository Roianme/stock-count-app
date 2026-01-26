import 'package:flutter/foundation.dart';
import '../model/item_model.dart' as model;
import '../data/item_data.dart' as data;
import '../data/item_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final model.Category category;
  final ItemRepository repository;
  List<model.Item> itemsInCategory = [];

  CategoryViewModel(this.category, {required this.repository}) {
    load();
  }

  void load() {
    itemsInCategory = data.items.where((i) => i.category == category).toList();
    notifyListeners();
  }

  /// Reload/refresh items from data source
  void reload() {
    load();
  }

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(status: newStatus);
      final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        itemsInCategory[idx] = data.items[mainIndex];
      }
      _saveItems();
      notifyListeners();
    }
  }

  void updateItemUnit(int itemId, String unit, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(
        unit: unit,
        status: newStatus,
      );
      final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        itemsInCategory[idx] = data.items[mainIndex];
      }
      _saveItems();
      notifyListeners();
    }
  }

  // Batch status update for multi-select operations
  void batchUpdateItemStatus(List<int> itemIds, model.ItemStatus newStatus) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          status: newStatus,
        );
        final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
        if (idx != -1) {
          itemsInCategory[idx] = data.items[mainIndex];
        }
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  void batchUpdateItemUnit(
    List<int> itemIds,
    String unit,
    model.ItemStatus newStatus,
  ) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          unit: unit,
          status: newStatus,
        );
        final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
        if (idx != -1) {
          itemsInCategory[idx] = data.items[mainIndex];
        }
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  void setItemQuantity(int itemId, int quantity) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(
        quantity: quantity,
      );
      final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        itemsInCategory[idx] = data.items[mainIndex];
      }
      _saveItems();
      notifyListeners();
    }
  }

  // Batch quantity update for multi-select operations
  void batchSetItemQuantity(List<int> itemIds, int quantity) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          quantity: quantity,
        );
        final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
        if (idx != -1) {
          itemsInCategory[idx] = data.items[mainIndex];
        }
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  void toggleItemChecked(int itemId) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(
        isChecked: !data.items[mainIndex].isChecked,
      );
      final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        itemsInCategory[idx] = data.items[mainIndex];
      }
      _saveItems();
      notifyListeners();
    }
  }

  // Batch check for multi-select operations
  void batchSetItemsChecked(List<int> itemIds, bool value) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          isChecked: value,
        );
        final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
        if (idx != -1) {
          itemsInCategory[idx] = data.items[mainIndex];
        }
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  void setAllChecked(bool value) {
    for (var i = 0; i < data.items.length; i++) {
      if (data.items[i].category == category) {
        data.items[i] = data.items[i].copyWith(isChecked: value);
      }
    }
    itemsInCategory = data.items.where((i) => i.category == category).toList();
    _saveItems();
    notifyListeners();
  }

  int get checkedItemsCount {
    return itemsInCategory.where((i) => i.isChecked).length;
  }

  int get totalItemsCount {
    return itemsInCategory.length;
  }

  String get itemsProgress {
    return '$checkedItemsCount/$totalItemsCount';
  }

  Future<void> _saveItems() async {
    try {
      await repository.saveItems(data.items);
    } catch (e) {
      debugPrint('Error saving items in CategoryViewModel: $e');
    }
  }
}
