import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/item_model.dart' as model;
import '../data/item_data.dart' as data;
import '../data/item_repository.dart';
import '../services/export_service.dart';

class HomeViewModel extends ChangeNotifier {
  final List<model.Category> allCategories;
  final ItemRepository repository;
  List<model.Category> visibleCategories;
  bool isGrid = true;
  bool isSearching = false;
  String _query = '';
  List<model.Item> matchedItems = [];

  HomeViewModel({required this.allCategories, required this.repository})
    : visibleCategories = List.from(allCategories);

  void toggleViewMode() {
    isGrid = !isGrid;
    notifyListeners();
  }

  // Dynamic search: updates matches while typing
  void setQuery(String q) {
    _query = q.trim().toLowerCase();
    if (_query.isEmpty) {
      isSearching = false;
      matchedItems = [];
      visibleCategories = List.from(allCategories);
    } else {
      isSearching = true;
      matchedItems = data.items
          .where((i) => i.name.toLowerCase().contains(_query))
          .toList();
      final matchedCategories = matchedItems
          .map((i) => i.category)
          .toSet()
          .toList();
      visibleCategories = allCategories
          .where((c) => matchedCategories.contains(c))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    setQuery('');
  }

  // void _applyFilter() {
  //   if (_query.isEmpty) {
  //     visibleCategories = List.from(allCategories);
  //   } else {
  //     visibleCategories = allCategories
  //         .where(
  //           (c) => c.toString().split('.').last.toLowerCase().contains(_query),
  //         )
  //         .toList();
  //   }
  //   notifyListeners();
  // }

  void setItemChecked(int itemId, bool value) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(isChecked: value);
    }
    final matchIndex = matchedItems.indexWhere((i) => i.id == itemId);
    if (matchIndex != -1) {
      matchedItems[matchIndex] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
  }

  List<model.Item> itemsForCategory(model.Category category) {
    return data.items.where((i) => i.category == category).toList();
  }

  Map<model.Category, List<model.Item>> groupedItems(
    List<model.Category> categories,
  ) {
    return {for (final c in categories) c: itemsForCategory(c)};
  }

  String categoryProgress(model.Category category) {
    final list = itemsForCategory(category);
    final checked = list.where((i) => i.isChecked).length;
    final total = list.length;
    return '$checked/$total checked';
  }

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(status: newStatus);
    }
    final matchIndex = matchedItems.indexWhere((i) => i.id == itemId);
    if (matchIndex != -1) {
      matchedItems[matchIndex] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
  }

  void setItemPieces(int itemId, int pieces) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(pieces: pieces);
    }

    final matchIndex = matchedItems.indexWhere((i) => i.id == itemId);
    if (matchIndex != -1) {
      matchedItems[matchIndex] = data.items.firstWhere((i) => i.id == itemId);
    }
    _saveItems();
    notifyListeners();
  }

  bool get hasCheckedItems => data.items.any((i) => i.isChecked);

  Future<void> _saveItems() async {
    try {
      await repository.saveItems(data.items);
    } catch (e) {
      print('Error saving items in HomeViewModel: $e');
    }
  }

  Future<bool> exportAndClear(
    BuildContext context, {
    String? location,
    String? name,
  }) async {
    final checkedItems = data.items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) {
      return false;
    }

    final success = await ExportService.exportAndShare(
      context,
      checkedItems,
      title: 'Stock Count Report',
      location: location,
      name: name,
    );

    if (success) {
      // Clear all checked items after successful export
      for (int i = 0; i < data.items.length; i++) {
        data.items[i] = data.items[i].copyWith(isChecked: false);
      }
      await _saveItems();
      notifyListeners();
    }

    return success;
  }

  Future<String?> saveToDeviceAndClear(
    BuildContext context, {
    String? location,
    String? name,
  }) async {
    final checkedItems = data.items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) {
      return null;
    }

    final filePath = await ExportService.saveToDevice(
      context,
      checkedItems,
      title: 'Stock Count Report',
      location: location,
      name: name,
    );

    if (filePath != null) {
      // Clear all checked items after successful save
      for (int i = 0; i < data.items.length; i++) {
        data.items[i] = data.items[i].copyWith(isChecked: false);
      }
      await _saveItems();
      notifyListeners();
    }

    return filePath;
  }
}
