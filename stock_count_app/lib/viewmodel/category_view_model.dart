import 'package:flutter/foundation.dart';
import '../model/item_model.dart' as model;
import '../data/item_data.dart' as data;

class CategoryViewModel extends ChangeNotifier {
  final model.Category category;
  List<model.Item> itemsInCategory = [];

  CategoryViewModel(this.category) {
    load();
  }

  void load() {
    itemsInCategory = data.items.where((i) => i.category == category).toList();
    notifyListeners();
  }

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      final updated = model.Item(
        id: data.items[mainIndex].id,
        name: data.items[mainIndex].name,
        category: data.items[mainIndex].category,
        status: newStatus,
      );
      data.items[mainIndex] = updated;
    }
    final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      itemsInCategory[idx] = data.items.firstWhere((i) => i.id == itemId);
    }
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
}
