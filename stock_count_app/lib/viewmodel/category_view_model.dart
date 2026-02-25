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

  void _updateItemById(int itemId, model.Item Function(model.Item) transform) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex == -1) return;

    data.items[mainIndex] = transform(data.items[mainIndex]);

    final idx = itemsInCategory.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      itemsInCategory[idx] = data.items[mainIndex];
    }

    _saveItems();
    notifyListeners();
  }

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    _updateItemById(itemId, (item) => item.copyWith(status: newStatus));
  }

  void updateItemUnit(int itemId, String unit, model.ItemStatus newStatus) {
    _updateItemById(
      itemId,
      (item) => item.copyWith(unit: unit, status: newStatus),
    );
  }

  void setItemQuantity(int itemId, int quantity) {
    _updateItemById(itemId, (item) => item.copyWith(quantity: quantity));
  }

  void applyItemQuantityChange(int itemId, int quantity) {
    _updateItemById(
      itemId,
      (item) => item.copyWith(quantity: quantity, isChecked: quantity > 0),
    );
  }

  void applyItemStatusChange(int itemId, model.ItemStatus newStatus) {
    _updateItemById(itemId, (item) {
      final shouldCheck = newStatus == model.ItemStatus.urgent
          ? true
          : item.quantity > 0;
      return item.copyWith(status: newStatus, isChecked: shouldCheck);
    });
  }

  void applyItemUnitChange(int itemId, data.ItemUnitOption newUnit) {
    final newStatus = newUnit.isUrgent
        ? model.ItemStatus.urgent
        : model.ItemStatus.quantity;

    _updateItemById(
      itemId,
      (item) => item.copyWith(
        unit: newUnit.label,
        status: newStatus,
        isChecked: true,
      ),
    );
  }

  void toggleItemChecked(int itemId) {
    _updateItemById(
      itemId,
      (item) => item.copyWith(isChecked: !item.isChecked),
    );
  }

  void setItemChecked(int itemId, bool value) {
    _updateItemById(itemId, (item) => item.copyWith(isChecked: value));
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
