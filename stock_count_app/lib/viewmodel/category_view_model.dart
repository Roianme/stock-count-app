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

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      final updated = data.items[mainIndex].copyWith(status: newStatus);
      data.items[mainIndex] = updated;
    }
    final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      itemsInCategory[idx] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
  }

  void setItemPieces(int itemId, int pieces) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      final updated = data.items[mainIndex].copyWith(pieces: pieces);
      data.items[mainIndex] = updated;
    }
    final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      itemsInCategory[idx] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
  }

  void toggleItemChecked(int itemId) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      final updated = data.items[mainIndex].copyWith(
        isChecked: !data.items[mainIndex].isChecked,
      );
      data.items[mainIndex] = updated;
    }
    final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      itemsInCategory[idx] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
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
