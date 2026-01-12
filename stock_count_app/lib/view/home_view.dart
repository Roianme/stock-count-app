import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../model/item_model.dart';
import '../viewmodel/home_view_model.dart';
import '../data/item_repository.dart';
import 'widgets/export_dialog.dart';
import 'widgets/preview_image_dialog.dart';
import 'widgets/app_drawer.dart';
import 'widgets/item_card_widget.dart';
import 'hp_view.dart';
import 'cafe_view.dart';
import 'warehouse_view.dart';
import 'category_view.dart';
import '../utils/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});
  final ItemRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<int> _selectedItemIds = {};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(
      allCategories: Category.values,
      repository: widget.repository,
    );
    viewModel.addListener(_handleViewModelChanges);
  }

  @override
  void dispose() {
    _searchController.dispose();
    viewModel.removeListener(_handleViewModelChanges);
    viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelChanges() {
    // Handle any notifications from ViewModel
    if (viewModel.showMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.showMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
      viewModel.clearMessage();
    }

    if (viewModel.previewImage != null) {
      _showImagePreviewDialog(viewModel.previewImage!);
      viewModel.clearPreviewImage();
    }

    if (viewModel.shouldShowExportDialog) {
      _showExportDialog();
      viewModel.clearExportDialogFlag();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        // Render different views based on location
        if (viewModel.currentLocation == Location.hp) {
          return PopScope(
            canPop: true,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: AppDrawer(
                currentLocation: viewModel.currentLocation,
                onLocationChanged: viewModel.setLocation,
              ),
              body: HpView(
                repository: widget.repository,
                onDrawerToggle: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          );
        }

        if (viewModel.currentLocation == Location.cafe) {
          return PopScope(
            canPop: true,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: AppDrawer(
                currentLocation: viewModel.currentLocation,
                onLocationChanged: viewModel.setLocation,
              ),
              body: CafeView(
                repository: widget.repository,
                onDrawerToggle: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          );
        }

        if (viewModel.currentLocation == Location.warehouse) {
          return PopScope(
            canPop: true,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: AppDrawer(
                currentLocation: viewModel.currentLocation,
                onLocationChanged: viewModel.setLocation,
              ),
              body: WarehouseView(
                repository: widget.repository,
                onDrawerToggle: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          );
        }

        // City location (default view)
        final categories = viewModel.visibleCategories;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: context.theme.background,
          appBar: _buildAppBar(),
          drawer: AppDrawer(
            currentLocation: viewModel.currentLocation,
            onLocationChanged: viewModel.setLocation,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxContentWidth = math.min(constraints.maxWidth, 1100.0);
                final isWide = constraints.maxWidth >= 900;
                final statusControlWidth = isWide ? 170.0 : 130.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      children: [
                        _buildSearchBar(isWide: isWide),
                        _buildSectionTitle(),
                        Expanded(
                          child: viewModel.isSearching
                              ? _buildSearchResults(viewModel.matchedItems)
                              : _buildListView(
                                  categories,
                                  statusControlWidth,
                                  isWide: isWide,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.theme.surface,
      elevation: 0,
      title: _isMultiSelectMode
          ? Text(
              '${_selectedItemIds.length} item${_selectedItemIds.length == 1 ? '' : 's'} selected',
              style: context.theme.appBarTitle.copyWith(
                color: context.theme.accent,
              ),
            )
          : Text(
              '${viewModel.currentLocation.displayName} - Stock Count',
              style: context.theme.appBarTitle,
            ),
      leading: _isMultiSelectMode
          ? IconButton(
              icon: Icon(Icons.close, color: context.theme.accent),
              onPressed: () {
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedItemIds.clear();
                });
              },
            )
          : IconButton(
              icon: Icon(Icons.menu, color: context.theme.textPrimary),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
      actions: _isMultiSelectMode
          ? []
          : [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Tooltip(
                  message: 'Preview checked items',
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: _handlePreviewAction,
                      child: Text(
                        'Preview',
                        style: TextStyle(
                          color: context.theme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Tooltip(
                  message: 'Export/Share checked items',
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: _handleExportAction,
                      child: Text(
                        'Export',
                        style: TextStyle(
                          color: context.theme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
    );
  }

  Widget _buildSearchBar({required bool isWide}) {
    return Container(
      color: context.theme.background,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive.horizontalPadding(),
        vertical: context.responsive.verticalPadding(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: context.theme.searchBarDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: viewModel.setQuery,
                style: TextStyle(fontSize: context.responsive.fontSize(16)),
                decoration: InputDecoration(
                  hintText: 'Search for keyword',
                  hintStyle: AppTheme.searchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.theme.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: context.theme.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            viewModel.setQuery('');
                          },
                          tooltip: 'Clear search',
                        )
                      : null,
                  fillColor: context.theme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: context.isLandscape ? 12 : 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    final titleText = viewModel.getSectionTitle();
    final showResetButton = !viewModel.isSearching;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSizes.spacingLarge,
        vertical: context.responsive.verticalPadding(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titleText,
              style: context.theme.sectionTitle.copyWith(
                fontSize: context.responsive.fontSize(20),
              ),
            ),
          ),
          if (showResetButton)
            TextButton.icon(
              onPressed: _handleResetAll,
              icon: Icon(Icons.refresh, size: 18, color: context.theme.accent),
              label: Text(
                'Reset',
                style: TextStyle(
                  color: context.theme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleResetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset items?'),
        content: const Text(
          'This will reset all item statuses, pieces, and checks back to their defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Reset', style: TextStyle(color: context.theme.accent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isMultiSelectMode = false;
      _selectedItemIds.clear();
    });
    await viewModel.resetAllToDefaults();
  }

  void _handlePreviewAction() {
    if (!viewModel.hasCheckedItems) {
      viewModel.setMessage('Please check items first');
      return;
    }
    viewModel.requestPreviewImage(context);
  }

  void _handleExportAction() {
    if (!viewModel.hasCheckedItems) {
      viewModel.setMessage('Please check items first');
      return;
    }
    viewModel.requestExportDialog();
  }

  Widget _buildListView(
    List<Category> categories,
    double statusControlWidth, {
    required bool isWide,
  }) {
    final itemsByCategory = viewModel.groupedItems(categories);
    final use3Columns = isWide || context.isLandscape;

    // Filter out empty categories
    final categoriesWithItems = categories.where((category) {
      final items = itemsByCategory[category] ?? [];
      return items.isNotEmpty;
    }).toList();

    // Lazy-load categories one by one
    final statusWidth = use3Columns ? 130.0 : statusControlWidth;

    if (!use3Columns) {
      // Single column for mobile - lazy load individual categories
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categoriesWithItems.length,
        cacheExtent: 500,
        itemBuilder: (context, index) {
          final category = categoriesWithItems[index];
          final items = itemsByCategory[category] ?? [];
          return RepaintBoundary(
            key: ValueKey(category),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...items.map(
                  (item) => _buildItemCard(item, statusWidth, hideIcon: true),
                ),
              ],
            ),
          );
        },
      );
    }

    // True masonry/waterfall layout: distribute categories across 3 columns
    // Each category goes to the shortest column for natural flow
    final columns = <List<Category>>[[], [], []];

    // Distribute categories round-robin for sequential loading
    for (int i = 0; i < categoriesWithItems.length; i++) {
      columns[i % 3].add(categoriesWithItems[i]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int colIndex = 0; colIndex < 3; colIndex++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: colIndex == 0 ? 0 : 2,
                  right: colIndex == 2 ? 0 : 2,
                ),
                child: _MasonryColumn(
                  categories: columns[colIndex],
                  itemsByCategory: itemsByCategory,
                  statusWidth: statusWidth,
                  isMultiSelectMode: _isMultiSelectMode,
                  selectedItemIds: _selectedItemIds,
                  viewModel: viewModel,
                  setState: setState,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    Category category,
    List<Item> items,
    double statusControlWidth,
  ) {
    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildItemCard(item, statusControlWidth, hideIcon: true),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    Item item,
    double statusControlWidth, {
    bool hideIcon = true,
  }) {
    return ItemCardWidget(
      item: item,
      statusControlWidth: statusControlWidth,
      hideIcon: hideIcon,
      isListView: true,
      onCheckChanged: () {
        if (_isMultiSelectMode) {
          return;
        }
        viewModel.setItemChecked(item.id, !item.isChecked);
      },
      onPiecesChanged: (pieces) {
        if (_isMultiSelectMode && _selectedItemIds.isNotEmpty) {
          // Batch apply pieces to all selected items
          viewModel.batchSetItemPieces(_selectedItemIds.toList(), pieces);
          // Then check all selected items if pieces > 0
          if (pieces > 0) {
            viewModel.batchSetItemsChecked(_selectedItemIds.toList(), true);
          }
          // Exit multi-select mode
          setState(() {
            _selectedItemIds.clear();
          });
        } else {
          viewModel.setItemPieces(item.id, pieces);
        }
      },
      onStatusChanged: (newStatus) {
        if (_isMultiSelectMode) {
          final idsToUpdate = {..._selectedItemIds, item.id}.toList();
          // Batch apply status to all selected items (plus the menu-target item)
          viewModel.batchUpdateItemStatus(idsToUpdate, newStatus);
          // Then check all affected items
          viewModel.batchSetItemsChecked(idsToUpdate, true);
          // Exit multi-select mode
          setState(() {
            _selectedItemIds.clear();
          });
        } else {
          viewModel.updateItemStatus(item.id, newStatus);
          viewModel.setItemChecked(item.id, true);
        }
      },
      showItemNameInColumn: true,
      isMultiSelectMode: _isMultiSelectMode,
      isSelected: _selectedItemIds.contains(item.id),
      onLongPress: () {
        setState(() {
          _selectedItemIds.add(item.id);
        });
      },
      onTap: () {
        setState(() {
          if (_selectedItemIds.contains(item.id)) {
            _selectedItemIds.remove(item.id);
          } else {
            _selectedItemIds.add(item.id);
          }
        });
      },
    );
  }

  Widget _buildSearchResults(List<Item> itemsList) {
    if (itemsList.isEmpty) {
      return const Center(child: Text('No matching items'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemsList.length,
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(item.name, style: context.theme.itemName),
              subtitle: Text(
                item.category.displayName,
                style: context.theme.subtitle,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        viewModel: viewModel,
        onExportSuccess: _showExportSuccess,
        onSaveSuccess: _showSaveSuccess,
        onError: _showError,
      ),
    );
  }

  void _showImagePreviewDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => PreviewImageDialog(imageBytes: imageBytes),
    );
  }

  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report shared successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSuccess(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(filePath),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

// Optimized masonry column with lazy loading
class _MasonryColumn extends StatelessWidget {
  final List<Category> categories;
  final Map<Category, List<Item>> itemsByCategory;
  final double statusWidth;
  final bool isMultiSelectMode;
  final Set<int> selectedItemIds;
  final HomeViewModel viewModel;
  final Function(VoidCallback) setState;

  const _MasonryColumn({
    required this.categories,
    required this.itemsByCategory,
    required this.statusWidth,
    required this.isMultiSelectMode,
    required this.selectedItemIds,
    required this.viewModel,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        final items = itemsByCategory[category] ?? [];
        return RepaintBoundary(
          key: ValueKey(category),
          child: _buildCategorySection(context, category, items),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    Category category,
    List<Item> items,
  ) {
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    if (homeState == null) return const SizedBox();

    return homeState._buildCategorySection(category, items, statusWidth);
  }
}
