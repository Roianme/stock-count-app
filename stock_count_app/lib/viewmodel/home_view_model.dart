import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/item_model.dart' as model;
import '../data/item_data.dart' as data;
import '../data/item_repository.dart';
import '../services/export_service_factory.dart';

class HomeViewModel extends ChangeNotifier {
  final List<model.Category> allCategories;
  final ItemRepository repository;
  List<model.Category> visibleCategories;
  bool isSearching = false;
  String _query = '';
  List<model.Item> matchedItems = [];
  model.Location currentLocation = model.Location.city;

  // UI state for dialogs and messages
  String? showMessage;
  Uint8List? previewImage;
  bool shouldShowExportDialog = false;

  HomeViewModel({required this.allCategories, required this.repository})
    : visibleCategories = List.from(allCategories);

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

  void setLocation(model.Location location) {
    if (currentLocation != location) {
      currentLocation = location;
      notifyListeners();
    }
  }

  void setItemChecked(int itemId, bool value) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(isChecked: value);
      _saveItems();
      notifyListeners();
    }
  }

  // Batch update for multi-select operations
  void batchSetItemsChecked(List<int> itemIds, bool value) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          isChecked: value,
        );
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
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

  String getSectionTitle() {
    if (isSearching) {
      return 'Search results';
    } else {
      return 'All Items';
    }
  }

  void updateItemStatus(int itemId, model.ItemStatus newStatus) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(status: newStatus);
      _saveItems();
      notifyListeners();
    }
  }

  // Batch status update for multi-select operations (no intermediate notifies)
  void batchUpdateItemStatus(List<int> itemIds, model.ItemStatus newStatus) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(
          status: newStatus,
        );
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  void setItemPieces(int itemId, int pieces) {
    final mainIndex = data.items.indexWhere((i) => i.id == itemId);
    if (mainIndex != -1) {
      data.items[mainIndex] = data.items[mainIndex].copyWith(pieces: pieces);
      _saveItems();
      notifyListeners();
    }
  }

  // Batch pieces update for multi-select operations (no intermediate notifies)
  void batchSetItemPieces(List<int> itemIds, int pieces) {
    bool updated = false;
    for (final itemId in itemIds) {
      final mainIndex = data.items.indexWhere((i) => i.id == itemId);
      if (mainIndex != -1) {
        data.items[mainIndex] = data.items[mainIndex].copyWith(pieces: pieces);
        updated = true;
      }
    }
    if (updated) {
      _saveItems();
      notifyListeners();
    }
  }

  Future<void> resetAllToDefaults() async {
    for (var i = 0; i < data.items.length; i++) {
      final current = data.items[i];
      final seed = data.seedItemsById[current.id];

      if (seed != null) {
        data.items[i] = seed.copyWith(isChecked: false);
      } else {
        data.items[i] = current.copyWith(
          status: model.ItemStatus.ok,
          pieces: 0,
          isChecked: false,
        );
      }
    }

    await _saveItems();

    // Refresh search results if searching
    if (_query.isNotEmpty) {
      matchedItems = data.items
          .where((i) => i.name.toLowerCase().contains(_query))
          .toList();
    }

    setMessage('All items reset to defaults');
    notifyListeners();
  }

  /// Reload/refresh the view state without resetting data
  void reload() {
    // Refresh search results if applicable
    if (_query.isNotEmpty) {
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
    } else {
      visibleCategories = List.from(allCategories);
    }
    notifyListeners();
  }

  bool get hasCheckedItems => data.items.any((i) => i.isChecked);

  // UI Message handling
  void setMessage(String message) {
    showMessage = message;
    notifyListeners();
  }

  void clearMessage() {
    showMessage = null;
  }

  void setPreviewImage(Uint8List image) {
    previewImage = image;
    notifyListeners();
  }

  void clearPreviewImage() {
    previewImage = null;
  }

  void requestExportDialog() {
    shouldShowExportDialog = true;
    notifyListeners();
  }

  void clearExportDialogFlag() {
    shouldShowExportDialog = false;
  }

  Future<void> _saveItems() async {
    try {
      await repository.saveItems(data.items);
    } catch (e) {
      debugPrint('Error saving items in HomeViewModel: $e');
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

    // Include all items in the report so unchecked ones appear struck through
    final allItems = List<model.Item>.from(data.items);

    final success = await ExportService.exportAndShare(
      context,
      allItems,
      title: 'Stock Count Report',
      location: location,
      name: name,
    );

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

    final allItems = List<model.Item>.from(data.items);

    final filePath = await ExportService.saveToDevice(
      context,
      allItems,
      title: 'Stock Count Report',
      location: location,
      name: name,
    );

    return filePath;
  }

  /// Generate preview image of the report without clearing items
  Future<Uint8List?> generatePreviewImage(BuildContext context) async {
    final checkedItems = data.items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) {
      return null;
    }

    final allItems = List<model.Item>.from(data.items);

    final image = await ExportService.generateReportImage(
      context,
      allItems,
      title: 'Stock Count Report',
      location: currentLocation.displayName,
      name: '',
    );

    return image;
  }

  Future<void> requestPreviewImage(BuildContext context) async {
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final image = await generatePreviewImage(context);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (image != null) {
      setPreviewImage(image);
    } else {
      setMessage('Failed to generate preview');
    }
  }
}
