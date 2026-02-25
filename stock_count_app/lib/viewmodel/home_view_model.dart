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
  model.Mode currentLocation = model.Mode.city;

  // Category expansion and view mode
  Set<model.Category> expandedCategories = {};
  bool isGridView = false;

  // UI state for dialogs and messages
  String? showMessage;
  Uint8List? previewImage;
  bool shouldShowExportDialog = false;

  HomeViewModel({required this.allCategories, required this.repository})
    : visibleCategories = List.from(allCategories);

  void _refreshSearchState() {
    if (_query.isEmpty) {
      isSearching = false;
      matchedItems = [];
      visibleCategories = List.from(allCategories);
      return;
    }

    isSearching = true;
    matchedItems = data.items
        .where(
          (i) =>
              i.modes.contains(currentLocation) &&
              i.name.toLowerCase().contains(_query),
        )
        .toList();

    final matchedCategories = matchedItems.map((i) => i.category).toSet();
    visibleCategories = allCategories
        .where((c) => matchedCategories.contains(c))
        .toList();
  }

  void _updateItemById(int itemId, model.Item Function(model.Item) transform) {
    final index = data.items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final current = data.items[index];
    data.items[index] = transform(current);
    _saveItems();
    notifyListeners();
  }

  // Dynamic search: updates matches while typing
  void setQuery(String q) {
    _query = q.trim().toLowerCase();
    _refreshSearchState();
    notifyListeners();
  }

  void clearSearch() {
    setQuery('');
  }

  void setLocation(model.Mode location) {
    if (currentLocation != location) {
      currentLocation = location;
      notifyListeners();
    }
  }

  void toggleCategoryExpanded(model.Category category) {
    if (expandedCategories.contains(category)) {
      expandedCategories.remove(category);
    } else {
      expandedCategories.add(category);
    }
    notifyListeners();
  }

  bool isCategoryExpanded(model.Category category) {
    return expandedCategories.contains(category);
  }

  void toggleViewMode() {
    isGridView = !isGridView;
    notifyListeners();
  }

  void expandAllCategories(List<model.Category> categories) {
    expandedCategories.addAll(categories);
    notifyListeners();
  }

  void collapseAllCategories() {
    expandedCategories.clear();
    notifyListeners();
  }

  void setItemChecked(int itemId, bool value) {
    _updateItemById(itemId, (item) => item.copyWith(isChecked: value));
  }

  List<model.Item> itemsForCategory(model.Category category) {
    return data.items
        .where(
          (i) => i.category == category && i.modes.contains(currentLocation),
        )
        .toList();
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

  Future<void> resetAllToDefaults() async {
    for (var i = 0; i < data.items.length; i++) {
      final current = data.items[i];
      final seed = data.seedItemsById[current.id];

      if (seed != null) {
        data.items[i] = seed.copyWith(isChecked: false);
      } else {
        data.items[i] = current.copyWith(
          status: model.ItemStatus.quantity,
          quantity: 0,
          isChecked: false,
        );
      }
    }

    await _saveItems();

    // Refresh search results if searching
    _refreshSearchState();

    setMessage('All items reset to defaults');
    notifyListeners();
  }

  /// Reload/refresh the view state without resetting data
  void reload() {
    _refreshSearchState();
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

    // Include only items that match the current mode
    final allItems = data.items
        .where((i) => i.modes.contains(currentLocation))
        .toList();

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

    // Include only items that match the current mode
    final allItems = data.items
        .where((i) => i.modes.contains(currentLocation))
        .toList();

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

    // Include only items that match the current mode
    final allItems = data.items
        .where((i) => i.modes.contains(currentLocation))
        .toList();

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
