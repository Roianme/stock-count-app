import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/item_model.dart';
import 'category_view.dart';
import '../viewmodel/home_view_model.dart';
import '../data/item_repository.dart';
import 'widgets/export_dialog.dart';
import 'widgets/preview_image_dialog.dart';
import 'widgets/app_drawer.dart';
import 'widgets/item_card_widget.dart';
import 'hp_view.dart';
import 'cafe_view.dart';
import 'warehouse_view.dart';
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
                              : (viewModel.isGrid
                                    ? _buildGridView(
                                        categories,
                                        maxContentWidth,
                                      )
                                    : _buildListView(
                                        categories,
                                        statusControlWidth,
                                      )),
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
                  fillColor: context.theme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: context.isLandscape ? 12 : 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: context.theme.searchBarDecoration,
            child: IconButton(
              icon: Icon(
                viewModel.isGrid ? Icons.view_list : Icons.grid_view,
                color: context.theme.textPrimary,
              ),
              onPressed: viewModel.toggleViewMode,
              tooltip: viewModel.isGrid
                  ? 'Switch to list view'
                  : 'Switch to grid view',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSizes.spacingLarge,
        vertical: context.responsive.verticalPadding(),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          viewModel.getSectionTitle(),
          style: context.theme.sectionTitle.copyWith(
            fontSize: context.responsive.fontSize(20),
          ),
        ),
      ),
    );
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

  Widget _buildGridView(List<Category> categories, double maxWidth) {
    final crossAxisCount = _gridCrossAxisCount(maxWidth);
    final aspectRatio = _gridChildAspectRatio(maxWidth, crossAxisCount);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  int _gridCrossAxisCount(double maxWidth) {
    return context.gridColumns;
  }

  double _gridChildAspectRatio(double maxWidth, int crossAxisCount) {
    return context.responsive.calculateAspectRatio(
      columns: crossAxisCount,
      targetHeight: 210.0,
    );
  }

  Widget _buildListView(List<Category> categories, double statusControlWidth) {
    final itemsByCategory = viewModel.groupedItems(categories);
    final listChildren = <Widget>[];

    for (final category in categories) {
      final categoryItems = itemsByCategory[category] ?? [];
      if (categoryItems.isEmpty) continue;

      listChildren.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category.displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );

      for (final item in categoryItems) {
        listChildren.add(_buildItemCard(item, statusControlWidth));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: listChildren,
    );
  }

  Widget _buildItemCard(Item item, double statusControlWidth) {
    return ItemCardWidget(
      item: item,
      statusControlWidth: statusControlWidth,
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
            _isMultiSelectMode = false;
            _selectedItemIds.clear();
          });
        } else {
          viewModel.setItemPieces(item.id, pieces);
        }
      },
      onStatusChanged: (newStatus) {
        if (_isMultiSelectMode && !_selectedItemIds.contains(item.id)) {
          setState(() {
            _selectedItemIds.add(item.id);
          });
        }
        if (_isMultiSelectMode && _selectedItemIds.isNotEmpty) {
          // Batch apply status to all selected items
          viewModel.batchUpdateItemStatus(_selectedItemIds.toList(), newStatus);
          // Then check all selected items
          viewModel.batchSetItemsChecked(_selectedItemIds.toList(), true);
          // Exit multi-select mode
          setState(() {
            _isMultiSelectMode = false;
            _selectedItemIds.clear();
          });
        } else {
          viewModel.updateItemStatus(item.id, newStatus);
        }
      },
      showItemNameInColumn: true,
      isMultiSelectMode: _isMultiSelectMode,
      isSelected: _selectedItemIds.contains(item.id),
      onLongPress: () {
        setState(() {
          _isMultiSelectMode = true;
          _selectedItemIds.add(item.id);
        });
      },
      onTap: () {
        setState(() {
          if (_selectedItemIds.contains(item.id)) {
            _selectedItemIds.remove(item.id);
            if (_selectedItemIds.isEmpty) {
              _isMultiSelectMode = false;
            }
          } else {
            _selectedItemIds.add(item.id);
          }
        });
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      decoration: context.theme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(ResponsiveSizes.borderRadiusXLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCategory(category),
          borderRadius: BorderRadius.circular(
            ResponsiveSizes.borderRadiusXLarge,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: context.responsive.iconSize(40),
                  color: category.color,
                ),
              ),
              SizedBox(height: context.isLandscape ? 8 : 12),
              Text(
                category.displayName,
                style: context.theme.cardTitle.copyWith(
                  fontSize: context.responsive.fontSize(16, 14),
                ),
              ),
              Text(
                viewModel.categoryProgress(category),
                style: TextStyle(
                  fontSize: context.responsive.fontSize(12, 10),
                  color: context.theme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(Category category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryView(category: category, repository: widget.repository),
      ),
    );
    setState(() {});
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
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.category.icon,
                  color: item.category.color,
                  size: 28,
                ),
              ),
              title: Text(item.name, style: context.theme.itemName),
              subtitle: Text(
                item.category.displayName,
                style: context.theme.subtitle,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.theme.textSecondary,
              ),
              onTap: () => _navigateToCategory(item.category),
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
        content: Text('Report shared and checks cleared!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSuccess(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report saved to:\n$filePath'),
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
