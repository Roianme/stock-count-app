import 'package:flutter/foundation.dart';
import '../model/item_model.dart' as model;
import '../view/category_view.dart' as category;

class HomeViewModel extends ChangeNotifier {
  final List<model.Category> allCategories;
  List<model.Category> visibleCategories;
  bool isGrid = true;
  String _query = '';

  HomeViewModel({required this.allCategories})
    : visibleCategories = List.from(allCategories);

  void toggleViewMode() {
    isGrid = !isGrid;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.trim().toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_query.isEmpty) {
      visibleCategories = List.from(allCategories);
    } else {
      visibleCategories = allCategories
          .where((c) => c.displayName.toLowerCase().contains(_query))
          .toList();
    }
    notifyListeners();
  }
}
