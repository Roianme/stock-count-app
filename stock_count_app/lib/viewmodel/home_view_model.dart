import 'package:flutter/foundation.dart';
import '../model/item_model.dart' as model;
import '../data/item_data.dart' as data;

class HomeViewModel extends ChangeNotifier {
  final List<model.Category> allCategories;
  List<model.Category> visibleCategories;
  bool isGrid = true;

  // New: search state
  bool isSearching = false;
  String _query = '';
  List<model.Item> matchedItems = [];

  HomeViewModel({required this.allCategories})
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
      // restore category list
      visibleCategories = List.from(allCategories);
    } else {
      isSearching = true;
      matchedItems = data.items
          .where((i) => i.name.toLowerCase().contains(_query))
          .toList();
      // optionally reduce visible categories to those that include matches
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

  void _applyFilter() {
    // kept for backward compatibility if needed elsewhere
    if (_query.isEmpty) {
      visibleCategories = List.from(allCategories);
    } else {
      visibleCategories = allCategories
          .where(
            (c) => c.toString().split('.').last.toLowerCase().contains(_query),
          )
          .toList();
    }
    notifyListeners();
  }

  // Add this method to HomeViewModel
  void setItemChecked(int itemId, bool value) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(isChecked: value);
    }
    // keep matchedItems in sync when searching
    final matchIndex = matchedItems.indexWhere((i) => i.id == itemId);
    if (matchIndex != -1) {
      matchedItems[matchIndex] = data.items.firstWhere((i) => i.id == itemId);
    }
    notifyListeners();
  }
}
