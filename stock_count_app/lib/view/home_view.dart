import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/item_model.dart';
import '../viewmodel/home_view_model.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart' as data;
import 'widgets/export_dialog.dart';
import 'widgets/preview_image_dialog.dart';
import 'widgets/app_drawer.dart';
import 'widgets/item_card_widget.dart';
import 'widgets/masonry_layout.dart';
import '../utils/index.dart';
import 'category_view.dart';

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
  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    _searchController.dispose();
    viewModel.removeListener(_handleViewModelChanges);
    viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelChanges() {
    if (!mounted) return;
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
        // Use the same view for all modes - filter items by currentLocation
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
                          child: _buildListView(
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
      title: Text(
        '${viewModel.currentLocation.displayName} - Stock Count',
        style: context.theme.appBarTitle,
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: context.theme.textPrimary),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sync, color: context.theme.textPrimary),
          onPressed: () {
            viewModel.reload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View refreshed'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Reload view',
        ),
        IconButton(
          icon: Icon(
            viewModel.isGridView ? Icons.view_list : Icons.grid_view,
            color: context.theme.textPrimary,
          ),
          onPressed: viewModel.toggleViewMode,
          tooltip: viewModel.isGridView
              ? 'Switch to list view'
              : 'Switch to grid view',
        ),
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
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  return TextField(
                    controller: _searchController,
                    onChanged: (text) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 200),
                        () => viewModel.setQuery(text),
                      );
                    },
                    style: TextStyle(fontSize: context.responsive.fontSize(16)),
                    decoration: InputDecoration(
                      hintText: 'Search for keyword',
                      hintStyle: AppTheme.searchHint,
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.theme.textSecondary,
                      ),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: context.theme.textSecondary,
                              ),
                              onPressed: () {
                                _searchDebounce?.cancel();
                                _searchController.clear();
                                // Remove focus so keyboard closes after clearing search
                                FocusScope.of(context).unfocus();
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
                  );
                },
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
          'This will reset all item statuses, quantities, and checks back to their defaults.',
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

    // Filter items based on search query
    final filteredItemsByCategory = <Category, List<Item>>{};
    if (viewModel.isSearching) {
      // Only show items that match the search
      final matchedIds = viewModel.matchedItems.map((i) => i.id).toSet();
      for (final category in categories) {
        final items = itemsByCategory[category] ?? [];
        final filtered = items
            .where((item) => matchedIds.contains(item.id))
            .toList();
        if (filtered.isNotEmpty) {
          filteredItemsByCategory[category] = filtered;
        }
      }
    } else {
      // Show all items
      filteredItemsByCategory.addAll(itemsByCategory);
    }

    final categoriesWithItems = categories
        .where((cat) => (filteredItemsByCategory[cat] ?? []).isNotEmpty)
        .toList();

    if (categoriesWithItems.isEmpty) {
      return const Center(child: Text('No items'));
    }

    final statusWidth = (isWide || context.isLandscape)
        ? 130.0
        : statusControlWidth;

    // Grid View: Categories displayed as square cards in a grid
    if (viewModel.isGridView) {
      final gridColumns = context.gridColumns + 1; // +1 for smaller cards
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0, // Square cards
        ),
        itemCount: categoriesWithItems.length,
        itemBuilder: (context, index) {
          final category = categoriesWithItems[index];
          final categoryItems = filteredItemsByCategory[category] ?? [];

          return RepaintBoundary(
            key: ValueKey('cat-${category.name}-$index'),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    // Navigate to category view
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryView(
                          category: category,
                          repository: viewModel.repository,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(category.icon, size: 48, color: category.color),
                        const SizedBox(height: 12),
                        Text(
                          category.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${categoryItems.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // List View: 3-column masonry layout
    final loopLength = categoriesWithItems.length;
    final shouldLoop = !viewModel.isSearching;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: shouldLoop ? null : loopLength,
      itemBuilder: (context, index) {
        final category =
            categoriesWithItems[shouldLoop ? index % loopLength : index];
        final categoryItems = filteredItemsByCategory[category] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header (not collapsible in list view)
            RepaintBoundary(
              key: ValueKey('h-${category.name}-$index'),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(color: category.color),
                width: double.infinity,
                child: Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Masonry layout for items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: MasonryLayout(
                items: categoryItems,
                statusWidth: statusWidth,
                buildItemCard: (item) =>
                    _buildItemCard(item, statusWidth, hideIcon: true),
              ),
            ),
          ],
        );
      },
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
        viewModel.setItemChecked(item.id, !item.isChecked);
      },
      onQuantityChanged: (quantity) {
        viewModel.applyItemQuantityChange(item.id, quantity);
      },
      onStatusChanged: (newStatus) {
        viewModel.applyItemStatusChange(item.id, newStatus);
      },
      onUnitChanged: (data.ItemUnitOption newUnit) {
        viewModel.applyItemUnitChange(item.id, newUnit);
      },
      showItemNameInColumn: true,
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
